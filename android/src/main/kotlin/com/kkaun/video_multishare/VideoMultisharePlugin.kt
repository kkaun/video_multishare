package com.kkaun.video_multishare

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VideoMultisharePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.kkaun.video_multi_share")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val videoPath = call.argument<String>("videoPath")
        if (videoPath.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENT", "Video path is null or empty", null)
            return
        }
        if (activity == null) {
            result.error("INVALID_ARGUMENT", "Attached Activity is null!", null)
            return
        }

        val (isSuccess, errorMessage) = when (call.method) {
            "shareToInstagramStory" -> VideoSharingDelegate.shareToInstagramStory(activity!!, videoPath)
            "shareToInstagramReels" -> VideoSharingDelegate.shareToInstagramWMethodPick(activity!!, videoPath)
            "shareToInstagramDirect" -> VideoSharingDelegate.shareToInstagramWMethodPick(activity!!, videoPath)
            "shareToFacebookPost" -> VideoSharingDelegate.shareToFacebookGenericOptions(activity!!, videoPath)
            "shareToFacebookStory" -> VideoSharingDelegate.shareToFacebookStory(activity!!, videoPath)
            "shareToYouTubeShorts" -> VideoSharingDelegate.shareToYouTubeShorts(activity!!, videoPath)
            "shareToTikTok" -> VideoSharingDelegate.shareToTikTok(activity!!, videoPath)
            "shareToWhatsApp" -> VideoSharingDelegate.shareToWhatsApp(activity!!, videoPath)
            "shareToSnapchat" -> VideoSharingDelegate.shareToSnapchat(activity!!, videoPath)
            else -> {
                result.notImplemented()
                return
            }
        }

        if (isSuccess) {
            result.success(true)
        } else {
            result.error("SHARE_FAILED", errorMessage, null)
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}
