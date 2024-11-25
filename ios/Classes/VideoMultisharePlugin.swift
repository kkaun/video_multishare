import Flutter
import UIKit

public class VideoMultisharePlugin: NSObject, FlutterPlugin {
    
    // Required Flutter plugin registration method
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.kkaun.video_multi_share", binaryMessenger: registrar.messenger())
        let instance = VideoMultisharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // Handle method calls from Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let videoPath = args["videoPath"] as? String,
              let videoURL = URL(string: videoPath) else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid video path", details: nil))
            return
        }
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        
        let (success, errorMessage): (Bool, String) = {
            switch call.method {
            case "shareToInstagramStory":
                return VideoSharingDelegate.shareToInstagramStory(videoURL: videoURL)
            case "shareToInstagramReels":
                return VideoSharingDelegate.shareToInstagramGeneric(videoURL: videoURL, viewController: viewController)
            case "shareToInstagramDirect":
                return VideoSharingDelegate.shareToInstagramGeneric(videoURL: videoURL, viewController: viewController)
            case "shareToFacebookPost":
                return VideoSharingDelegate.shareToFacebookGeneric(videoURL: videoURL, viewController: viewController)
            case "shareToFacebookStory":
                return VideoSharingDelegate.shareToFacebookStory(videoURL: videoURL)
            case "shareToYouTubeShorts":
                return VideoSharingDelegate.shareToYouTube(videoURL: videoURL)
            case "shareToWhatsApp":
                return VideoSharingDelegate.shareToWhatsApp(videoURL: videoURL)
            case "shareToTikTok":
                guard let redirectURI = args["redirectURI"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing redirectURI", details: nil))
                    return (false, "Missing redirectURI")
                }
                VideoSharingDelegate.shareToTikTok(videoURL: videoURL, redirectURI: redirectURI) { shareResult in
                    DispatchQueue.main.async {
                        switch shareResult {
                        case .success(let message):
                            result(message)
                        case .failure(let error):
                            result(FlutterError(code: "SHARE_FAILED", message: error.localizedDescription, details: nil))
                        }
                    }
                }
            case "shareToSnapchat":
                VideoSharingDelegate.shareToSnapchat(videoURL: videoURL, viewController: viewController) { shareResult in
                    switch shareResult {
                    case .success(let message):
                        result(message)
                    case .failure(let error):
                        result(FlutterError(code: "SHARE_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            default:
                return (false, "Method not implemented")
            }
            return (false, "Method not implemented")
        }()
        
        if success {
            result(true)
        } else {
            result(FlutterError(code: "SHARE_FAILED", message: errorMessage, details: nil))
        }
    }
}
