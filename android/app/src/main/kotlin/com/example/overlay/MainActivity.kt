package com.example.overlay

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SCREEN_CAPTURE_REQUEST_CODE = 1001
    private lateinit var mediaProjectionManager: MediaProjectionManager

    // Define the channel name as a constant
    companion object {
        const val CHANNEL = "com.example.screenshot/capture"
    }

    // This method is called when the FlutterEngine is created.
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create the MethodChannel with the provided name
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "captureScreenshot" -> {
                            startScreenCapture()
                            result.success(null)
                        }
                        "onTextDetected" -> {
                            // Handle detected text here
                            val detectedText = call.arguments as String
                            // You can use detectedText as needed, for example, print it or store it
                            println("Detected text from service: $detectedText")
                            result.success(null)
                        }
                        else -> result.notImplemented()
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
