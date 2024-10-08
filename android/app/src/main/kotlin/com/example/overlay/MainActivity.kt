package com.example.overlay

import android.content.Intent
import android.media.projection.MediaProjectionManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.overlay/screenshot"
    private val REQUEST_CODE = 1000

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register FlutterEngine to be accessible in ScreenshotService
        FlutterEngineCache.getInstance().put("my_engine_id", flutterEngine)

        // Register the plugins
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // Setting up the method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestProjection" -> {
                    requestScreenCapture(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestScreenCapture(result: MethodChannel.Result) {
        val mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val intent = mediaProjectionManager.createScreenCaptureIntent()
        startActivityForResult(intent, REQUEST_CODE)
        result.success(REQUEST_CODE)  // Notify Flutter that the request was initiated
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE && resultCode == RESULT_OK) {
            val screenshotServiceIntent = Intent(this, ScreenshotService::class.java).apply {
                putExtra("RESULT_CODE", resultCode)
                putExtra("RESULT_DATA", data)
            }
            startService(screenshotServiceIntent) // Start your screenshot service
        } else {
            // You may want to handle the case where permission was not granted
            // For example, you could send a message back to Flutter
        }
    }
}
