package com.kkaun.video_multishare

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import java.io.File

object VideoSharingDelegate {

    private val TAG = "VideoSharingDelegate"

    private fun getContentUri(context: Context, file: File): Uri {
        return FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider", // Matches authority defined in AndroidManifest.xml
            file
        )
    }

    // ---------------------------------- Instagram Sharing Methods
    fun shareToInstagramStory(context: Context, videoPath: String): Pair<Boolean, String> {
        Log.d(TAG, "Attempting to share to Instagram Story...")
        val file = File(videoPath)
        if (!file.exists()) {
            Log.d(TAG, "File does not exist: $videoPath")
            return Pair(false, "File does not exist")
        }

        val uri = getContentUri(context, file)
        Log.d(TAG, "Generated content URI: $uri")

        val intent = Intent("com.instagram.share.ADD_TO_STORY").apply {
            setDataAndType(uri, "video/mp4")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            `package` = "com.instagram.android"
        }

        return try {
            context.startActivity(intent)
            Pair(true, "")
        } catch (e: Exception) {
            Log.d(TAG, "Failed to share to Instagram Story: ${e.localizedMessage}")
            Log.d(TAG, e.stackTraceToString())
            Pair(false, "Failed to share to Instagram Story: ${e.localizedMessage}")
        }
    }

    // Unless we launch the specific intent for the Stories use case,
    // Instagram does not provide any genuine solutions for bypassing the manual selection process
    // for direct sharing. So, for all other common sharing cases this common method should be used:
    fun shareToInstagramWMethodPick(context: Context, videoPath: String): Pair<Boolean, String> {
        Log.d(TAG, "Attempting to share to Instagram Reels...")
        val file = File(videoPath)
        if (!file.exists()) {
            Log.d(TAG, "File does not exist: $videoPath")
            return Pair(false, "File does not exist")
        }

        val uri = getContentUri(context, file)
        Log.d(TAG, "Generated content URI: $uri")

        val intent = Intent(Intent.ACTION_SEND).apply {
            setDataAndType(uri, "video/mp4")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            `package` = "com.instagram.android"
        }

        return try {
            context.startActivity(intent)
            Pair(true, "")
        } catch (e: Exception) {
            Log.d(TAG, "Failed to share to Instagram Reels: ${e.localizedMessage}")
            Log.d(TAG, e.stackTraceToString())
            Pair(false, "Failed to share to Instagram Reels: ${e.localizedMessage}")
        }
    }

    // ---------------------------------- Facebook Sharing Methods
    fun shareToFacebookGenericOptions(context: Context, videoPath: String): Pair<Boolean, String> {
        Log.d(TAG, "Attempting to share to Facebook Post...")
        val file = File(videoPath)
        if (!file.exists()) {
            Log.d(TAG, "File does not exist: $videoPath")
            return Pair(false, "File does not exist")
        }

        val uri = getContentUri(context, file)
        Log.d(TAG, "Generated content URI: $uri")

        val intent = Intent(Intent.ACTION_SEND).apply {
            setDataAndType(uri, "video/mp4")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            `package` = "com.facebook.katana"
        }

        return try {
            context.startActivity(intent)
            Pair(true, "")
        } catch (e: Exception) {
            Log.d(TAG, "Failed to share to Facebook Post: ${e.localizedMessage}")
            Log.d(TAG, e.stackTraceToString())
            Pair(false, "Failed to share to Facebook Post: ${e.localizedMessage}")
        }
    }

    fun shareToFacebookStory(context: Context, videoPath: String): Pair<Boolean, String> {
        Log.d(TAG, "Attempting to share to Facebook Story...")
        val file = File(videoPath)
        if (!file.exists()) {
            Log.d(TAG, "File does not exist: $videoPath")
            return Pair(false, "File does not exist")
        }

        val uri = getContentUri(context, file)
        Log.d(TAG, "Generated content URI: $uri")

        val intent = Intent("com.facebook.stories.ADD_TO_STORY").apply {
            setDataAndType(uri, "video/mp4")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            `package` = "com.facebook.katana"
        }

        return try {
            context.startActivity(intent)
            Pair(true, "")
        } catch (e: Exception) {
            Log.d(TAG, "Failed to share to Facebook Story: ${e.localizedMessage}")
            Log.d(TAG, e.stackTraceToString())
            Pair(false, "Failed to share to Facebook Story: ${e.localizedMessage}")
        }
    }

    // ---------------------------------- YouTube Shorts Sharing
    fun shareToYouTubeShorts(context: Context, videoPath: String): Pair<Boolean, String> {
        val file = File(videoPath)
        if (!file.exists()) return Pair(false, "File does not exist")

        val uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            file
        )
        val intent = Intent(Intent.ACTION_SEND).apply {
            setDataAndType(uri, "video/mp4")
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) // Add this flag
            `package` = "com.google.android.youtube"
        }

        return try {
            context.startActivity(Intent.createChooser(intent, "Share to YouTube Shorts"))
            Pair(true, "")
        } catch (e: Exception) {
            Pair(false, "Failed to share to YouTube Shorts: ${e.localizedMessage}")
        }
    }

    // ---------------------------------- TikTok Sharing
    fun shareToTikTok(context: Context, videoPath: String): Pair<Boolean, String> {
        Log.d(TAG, "Attempting to share to TikTok...")
        val file = File(videoPath)
        if (!file.exists()) {
            Log.d(TAG, "File does not exist: $videoPath")
            return Pair(false, "File does not exist")
        }

        val uri = getContentUri(context, file)
        Log.d(TAG, "Generated content URI: $uri")

        val intent = Intent("android.intent.action.SEND").apply {
            setPackage("com.zhiliaoapp.musically")
            putExtra(Intent.EXTRA_STREAM, uri)
            type = "video/mp4"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        return try {
            context.startActivity(intent)
            Pair(true, "")
        } catch (e: Exception) {
            Log.d(TAG, "Failed to share to TikTok: ${e.localizedMessage}")
            Log.d(TAG, e.stackTraceToString())
            Pair(false, "Failed to share to TikTok: ${e.localizedMessage}")
        }
    }

    // ---------------------------------- WhatsApp Sharing
    fun shareToWhatsApp(context: Context, videoPath: String): Pair<Boolean, String> {
        Log.d(TAG, "Attempting to share to WhatsApp...")
        val file = File(videoPath)
        if (!file.exists()) {
            Log.d(TAG, "File does not exist: $videoPath")
            return Pair(false, "File does not exist")
        }

        val uri = getContentUri(context, file)
        Log.d(TAG, "Generated content URI: $uri")

        val intent = Intent(Intent.ACTION_SEND).apply {
            setPackage("com.whatsapp")
            putExtra(Intent.EXTRA_STREAM, uri)
            type = "video/mp4"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        return try {
            context.startActivity(Intent.createChooser(intent, "Share to WhatsApp"))
            Pair(true, "")
        } catch (e: Exception) {
            Log.d(TAG, "Failed to share to WhatsApp: ${e.localizedMessage}")
            Log.d(TAG, e.stackTraceToString())
            Pair(false, "Failed to share to WhatsApp: ${e.localizedMessage}")
        }
    }

    // ---------------------------------- Snapchat Sharing
    fun shareToSnapchat(context: Context, videoPath: String): Pair<Boolean, String> {
        Log.d(TAG, "Attempting to share to Snapchat...")
        val file = File(videoPath)
        if (!file.exists()) {
            Log.d(TAG, "File does not exist: $videoPath")
            return Pair(false, "File does not exist")
        }

        val uri = getContentUri(context, file)
        Log.d(TAG, "Generated content URI: $uri")

        val intent = Intent("android.intent.action.SEND").apply {
            setPackage("com.snapchat.android")
            putExtra(Intent.EXTRA_STREAM, uri)
            type = "video/mp4"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        return try {
            context.startActivity(intent)
            Pair(true, "")
        } catch (e: Exception) {
            Log.d(TAG, "Failed to share to Snapchat: ${e.localizedMessage}")
            Log.d(TAG, e.stackTraceToString())
            Pair(false, "Failed to share to Snapchat: ${e.localizedMessage}")
        }
    }
}
