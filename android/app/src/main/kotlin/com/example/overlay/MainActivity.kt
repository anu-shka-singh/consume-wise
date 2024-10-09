package com.example.overlay

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SCREEN_CAPTURE_REQUEST_CODE = 1001
    private lateinit var mediaProjectionManager: MediaProjectionManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make sure this matches the channel string in your Flutter code
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger ?: return, "com.example.screenshot/capture")
            .setMethodCallHandler { call, result ->
                if (call.method == "captureScreenshot") {
                    startScreenCapture()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun startScreenCapture() {
        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        startActivityForResult(mediaProjectionManager.createScreenCaptureIntent(), SCREEN_CAPTURE_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == SCREEN_CAPTURE_REQUEST_CODE) {
            val screenshotIntent = Intent(this, ScreenshotService::class.java)
            screenshotIntent.putExtra("resultCode", resultCode)
            screenshotIntent.putExtra("data", data)
            startService(screenshotIntent)
        }
    }
}
