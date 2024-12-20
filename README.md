# Video Multishare Plugin
A Flutter plugin that enables seamless video sharing to popular platforms such as Instagram, Facebook, TikTok, YouTube, WhatsApp, and Snapchat. It simplifies the sharing process by leveraging native platform-specific APIs and intents for both Android and iOS.

## Features
Share videos directly to (including sharing sub-methods):
- Instagram
- Facebook
- TikTok
- YouTube
- WhatsApp
- Snapchat

Built-in support for file URI conversions to ensure compatibility.
Cross-platform support for Android and iOS.

Currently, plugin uses the following Flutter/SDK versions:
```
sdk: ^3.5.4
flutter: '>=3.3.0'
```

## Integration of the Plugin from Local File System

First, clone the plugin project to the local file system.

1. Add the plugin as a dependency in your pubspec.yaml:
```
dependencies:
  video_multishare:
    path: ../your_local_path_to_plugin_repo
```

2. Run ```flutter pub get```

3. Import: ```import 'package:video_multishare/video_multishare.dart';```

4. Call the plugin from the Flutter code (event/click/etc.):
```
await VideoMultishare.requestShareOptions(
  context: context,
  videoPath: _pickedVideoPath ?? "",
  onShareResult: (message) {
    //Do anything with result message,
    // which either indicates the sharing led
    // to the external app flow or to an error.
  },
);
```

## Android Setup
Andorid setup is pretty simple and contains mostly optional points for overall functionality to work flawlessly.

Update *AndroidManifest.xml* .
(Mandatory for Instagram) Add the following intent filter to your AndroidManifest.xml to support platform-specific sharing flows:

```
    <intent-filter>
        <action android:name="com.instagram.share.ADD_TO_STORY" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
```

If your app supports file sharing, you should to check if it overrides such of the plugin's *file_paths.xml*.  in /android/main/res/xml/:
```
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="." />
    <files-path name="internal_files" path="." />
    <cache-path name="cache" path="." />
</paths>
```
Otherwise, you can ignore that point.

Set the permissions (may be optional and heavily depending on the app video file composal flow):
```
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
FYI: An Android sharing composal flow uses common video URI providing mechanism before triggering any share intent, which works universally good for all described services, so storage permissions usage may or may not be mandatory depending on you app's file mgmt logic (f.e. for the example app it's mandatory, but for the other one may be not).

## iOS Setup

Due to various platform requirements and limitations for the targeted services, iOS setup requires more extra actions.

#### Important Disclaimer for iOS Setup:
To use the full capabilities of the plugin on iOS, your app must be already registered within the corresponding developer portals:

- Instagram Developer Portal: For Instagram Stories and Reels sharing support.
- TikTok Developer Portal: For TikTok sharing support.
- Facebook Developer Portal: For Facebook sharing support.
- Snapchat Developer Portal: For Snap sharing support.

Without the proper consumer app registraction, such services will not support direct sharing on any iOS device.

! Provided Flutter example app does not contain such valid keys for the number of objective reasons, and mainly because most of the services from this list won't allow valid creds generation for an unpublished Flutter plugin sample app.

##### Capabilities:
Add the following capabilities to your Info.plist:

```
<key>NSPhotoLibraryUsageDescription</key>
<string>Ex.: We need access to your photo library to pick files.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Ex.: We need access to save selected files to your photo library.</string>
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UISupportsDocumentBrowser</key>
<true/>
```

##### LSApplicationQueriesSchemes:
Add the following schemes to your Info.plist to enable sharing functionality with supported apps:

```
<key>LSApplicationQueriesSchemes</key>
<array>
    <!-- Instagram -->
    <string>instagram</string>
    <string>instagram-stories</string>
    <!-- Facebook -->
    <string>fb</string>
    <string>facebook-stories</string>
    <!-- TikTok -->
    <string>tiktokopensdk</string>
    <string>tiktoksharesdk</string>
    <string>snssdk1180</string>
    <string>snssdk1233</string>
    <!-- YouTube -->
    <string>youtube</string>
    <string>youtube-shorts</string>
    <!-- WhatsApp -->
    <string>whatsapp</string>
    <!-- Snapchat -->
    <string>snapchat</string>
</array>

```

##### Keys:
Add your(!) app service keys for platform-specific configurations necessary for each platform default integration support, such as:

```
<key>TikTokClientKey</key>
<string>$TikTokClientKey</string>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <string>$TikTokClientKey</string>
    </dict>
</array>
<key>SCSDKClientId</key>
<string>your_snapchat_client_id</string>
<key>FacebookAppID</key>
<string>your_facebook_app_id</string>
```

#### Regarding some generic sharing options on iOS:

- Due to FB SDK complexity in the context of integration into any kind of iOS Framework (as a part of Flutter plugin), only FB Stories functionality is left for iOS. It's way easier to integrate FB SDK into the own app's ios/ structure, rather then into Flutter plugin/package.

- As known, YouTube Shorts sharing was replaced by simple YT Video Upload flow, again due to iOS-related restrictions.

- Content descrption for some sharing methods (like Snapchat) can be additionally customized via VideoSharingDelegate.swift manual adjustment.

