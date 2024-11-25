import UIKit
import Photos
import TikTokOpenSDKCore
import TikTokOpenShareSDK
import SCSDKCreativeKit

class VideoSharingDelegate: NSObject, UIDocumentInteractionControllerDelegate {
    
    // Singleton instance for the delegate
    static let shared: UIDocumentInteractionControllerDelegate = VideoSharingDelegate()

    // Helper function for logging
    private static func logShareSuccess(to appName: String) {
        print("Successfully shared to \(appName).")
    }

    private static func logShareFailure(to appName: String, error: String) {
        print("Failed to share to \(appName): \(error).")
    }

    // Singleton instance of DocumentInteractionController
    private static var documentInteractionController: UIDocumentInteractionController?

    // UIDocumentInteractionControllerDelegate method (optional customization)
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        print("Instagram Feed sharing menu dismissed.")
    }

    // Share to Instagram Story
    static func shareToInstagramStory(videoURL: URL) -> (Bool, String) {
        guard let instagramURL = URL(string: "instagram-stories://share") else {
            print("Invalid Instagram URL scheme.")
            return (false, "Invalid Instagram URL scheme.")
        }

        guard UIApplication.shared.canOpenURL(instagramURL) else {
            print("Instagram is not installed on this device.")
            return (false, "Instagram is not installed on this device.")
        }

        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundVideo": videoURL,
            "com.instagram.sharedSticker.contentURL": "https://yourapp.com" // Optional
        ]

        if #available(iOS 10.0, *) {
            UIPasteboard.general.setItems([pasteboardItems], options: [.expirationDate: Date().addingTimeInterval(60 * 5)])
        } else {
            UIPasteboard.general.items = [pasteboardItems]
        }

        UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
        return (true, "Sharing in progress...")
    }

    // Share video to Instagram Feed etc.
    static func shareToInstagramGeneric(videoURL: URL, viewController: UIViewController) -> (Bool, String) {
        saveVideoToCameraRoll(videoURL: videoURL) { success, error in
            if success {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1

                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                if let lastAsset = fetchResult.firstObject {
                    let localIdentifier = lastAsset.localIdentifier
                    let urlString = "instagram://library?LocalIdentifier=\(localIdentifier)"
                    if let url = URL(string: urlString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            print("Unable to open Instagram.")
                        }
                    }
                }
            } else {
                print("Error saving video to camera roll: \(error ?? "Unknown error")")
            }
        }
        return (true, "")
    }
    
    // Share to Facebook Post: Not implemented, because it's more realistic to intgrate FB SDK on the iOS app side, rather than Flutter ios plugin
    static func shareToFacebookGeneric(videoURL: URL, viewController: UIViewController) -> (Bool, String) {
        logShareSuccess(to: "Facebook Post/Generic")
        return (false, "Not implemented; FB SPM dependency should be used for FB generic sharing, which is not flexible solution.")
    }

    // Share to Facebook Story
    static func shareToFacebookStory(videoURL: URL) -> (Bool, String) {
        let facebookURL = URL(string: "facebook-stories://share?source=\(videoURL.absoluteString)")!

        if UIApplication.shared.canOpenURL(facebookURL) {
            UIApplication.shared.open(facebookURL)
            logShareSuccess(to: "Facebook Story")
            return (true, "")
        } else {
            let errorMessage = "Facebook Story sharing failed: app not available."
            logShareFailure(to: "Facebook Story", error: errorMessage)
            return (false, errorMessage)
        }
    }

    // Share to YouTube: Instead of Shorts, using the generic YT flow for video upload (iOS only)
    static func shareToYouTube(videoURL: URL) -> (Bool, String) {
        // Ensure the video file exists
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            let errorMessage = "Video file not found at path: \(videoURL.path)"
            logShareFailure(to: "YouTube", error: errorMessage)
            return (false, errorMessage)
        }

        // Construct the YouTube upload URL
        let youtubeURL = URL(string: "youtube://upload?source=\(videoURL.absoluteString)")!

        // Check if YouTube is installed and can handle the URL scheme
        if UIApplication.shared.canOpenURL(youtubeURL) {
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
            logShareSuccess(to: "YouTube")
            return (true, "Video shared to YouTube successfully.")
        } else {
            let errorMessage = "YouTube sharing failed: app not available."
            logShareFailure(to: "YouTube", error: errorMessage)
            return (false, errorMessage)
        }
    }

    // Share to WhatsApp
    static func shareToWhatsApp(videoURL: URL) -> (Bool, String) {
        let whatsappURL = URL(string: "whatsapp://send?text=\(videoURL.absoluteString)")!

        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
            logShareSuccess(to: "WhatsApp")
            return (true, "")
        } else {
            let errorMessage = "WhatsApp sharing failed: app not available."
            logShareFailure(to: "WhatsApp", error: errorMessage)
            return (false, errorMessage)
        }
    }
    
    // Share to TikTok
    static func shareToTikTok(videoURL: URL, redirectURI: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Check if TikTok is installed
        guard UIApplication.shared.canOpenURL(URL(string: "snssdk1233://")!) else {
            let error = NSError(domain: "TikTok", code: 404, userInfo: [NSLocalizedDescriptionKey: "TikTok is not installed on this device."])
            completion(.failure(error))
            return
        }

        // Save video to Photos Library
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
            if success {
                // Fetch the recently added asset
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1

                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)

                if let lastAsset = fetchResult.firstObject {
                    let localIdentifier = lastAsset.localIdentifier

                    // Create TikTok share request
                    let shareRequest = TikTokShareRequest(localIdentifiers: [localIdentifier], mediaType: .video, redirectURI: redirectURI)

                    // Send the share request
                    shareRequest.send { response in
                        if let shareResponse = response as? TikTokShareResponse, shareResponse.errorCode == .noError {
                            completion(.success("Video shared successfully to TikTok."))
                        } else {
                            let errorMessage = (response as? TikTokShareResponse)?.errorDescription ?? "Unknown error."
                            let error = NSError(domain: "TikTok", code: 500, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                            completion(.failure(error))
                        }
                    }
                } else {
                    let error = NSError(domain: "TikTok", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch the video asset."])
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                let error = NSError(domain: "TikTok", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unknown error saving media."])
                completion(.failure(error))
            }
        }
    }

    //Share to Snapchat (it could be sufficient to additionally play with the content description data)
    static func shareToSnapchat(videoURL: URL, viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        // Check if Snapchat is installed
        guard UIApplication.shared.canOpenURL(URL(string: "snapchat://")!) else {
            completion(.failure(NSError(domain: "Snapchat", code: 404, userInfo: [NSLocalizedDescriptionKey: "Snapchat is not installed on this device."])))
            return
        }
        // Verify video file existence
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            completion(.failure(NSError(domain: "Snapchat", code: 400, userInfo: [NSLocalizedDescriptionKey: "Video file not found at path: \(videoURL.path)"])))
            return
        }

        // Create Snapchat video content
        let snapVideo = SCSDKSnapVideo(videoUrl: videoURL)
        let snapContent = SCSDKVideoSnapContent(snapVideo: snapVideo)
        snapContent.caption = "Check out this video!"

        // Optional: Add a URL to the content
        //snapContent.attachmentUrl = "https://yourcompany.com"

        // Present the Snapchat share screen
        let snapAPI = SCSDKSnapAPI(content: snapContent)
        snapAPI.startSnapping { error in
            if let error = error {
                let errorMessage = error.localizedDescription
                completion(.failure(NSError(domain: "Snapchat", code: 500, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            } else {
                completion(.success("Video shared successfully to Snapchat."))
            }
        }
    }

    // Generic share function using activity view controller
    static func shareToGenericApp(videoURL: URL, viewController: UIViewController, appName: String) -> (Bool, String) {
        let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
        logShareSuccess(to: appName)
        return (true, "")
    }
    
    // Save video to camera roll (required for some Instagram scenarios)
    static func saveVideoToCameraRoll(videoURL: URL, completion: @escaping (Bool, String?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

}
