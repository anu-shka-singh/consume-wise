package com.example.overlay

import android.app.Service
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Handler
import android.os.IBinder
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngineCache
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import android.net.Uri
import android.hardware.display.DisplayManager
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text // Ensure this import exists
import com.google.android.gms.tasks.Task // Add this import for Task

class ScreenshotService : Service() {
    private lateinit var mediaProjectionManager: MediaProjectionManager
    private lateinit var mediaProjection: MediaProjection
    private lateinit var imageReader: ImageReader
    private var resultCode: Int = 0
    private var resultData: Intent? = null
    private val CHANNEL = "com.example.overlay/screenshott"
    private val handler = Handler()

    override fun onCreate() {
        super.onCreate()
        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        resultCode = intent?.getIntExtra("RESULT_CODE", Activity.RESULT_OK) ?: Activity.RESULT_OK
        resultData = intent?.getParcelableExtra("RESULT_DATA")

        if (resultData != null) {
            startCaptureScreen()
        } else {
            Log.e("ScreenshotService", "Permission not granted or invalid result data")
        }

        return START_NOT_STICKY
    }

    private fun startCaptureScreen() {
        mediaProjection = mediaProjectionManager.getMediaProjection(resultCode, resultData!!)
        val metrics = DisplayMetrics()
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager.defaultDisplay.getMetrics(metrics)

        imageReader = ImageReader.newInstance(metrics.widthPixels, metrics.heightPixels, PixelFormat.RGBA_8888, 2)
        val virtualDisplay = mediaProjection.createVirtualDisplay(
                "ScreenCapture",
                metrics.widthPixels,
                metrics.heightPixels,
                metrics.densityDpi,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                imageReader.surface,
                null,
                handler
        )

        imageReader.setOnImageAvailableListener(object : ImageReader.OnImageAvailableListener {
            override fun onImageAvailable(reader: ImageReader) {
                val image = reader.acquireLatestImage()
                if (image != null) {
                    val planes = image.planes
                    val buffer: ByteBuffer = planes[0].buffer
                    val width = image.width
                    val height = image.height
                    val pixelStride = planes[0].pixelStride
                    val rowStride = planes[0].rowStride
                    val rowPadding = rowStride - pixelStride * width
                    val bitmap = Bitmap.createBitmap(
                            width + rowPadding / pixelStride,
                            height,
                            Bitmap.Config.ARGB_8888
                    )
                    bitmap.copyPixelsFromBuffer(buffer)
                    image.close()

                    saveScreenshotAndExtractText(bitmap)

                    virtualDisplay.release()
                    imageReader.close()
                    mediaProjection.stop()
                    stopSelf() // Stop the service after completing the task
                }
            }
        }, handler)
    }

    private fun saveScreenshotAndExtractText(bitmap: Bitmap) {
        try {
            val screenshotFile = File(getExternalFilesDir(null), "screenshot.png")
            val outputStream = FileOutputStream(screenshotFile)
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            outputStream.flush()
            outputStream.close()

            Log.d("ScreenshotService", "Screenshot saved at: ${screenshotFile.absolutePath}")
            extractTextFromImage(screenshotFile.absolutePath)
        } catch (e: Exception) {
            Log.e("ScreenshotService", "Failed to save screenshot", e)
        }
    }

    private fun extractTextFromImage(imagePath: String) {
        val image = InputImage.fromFilePath(this, Uri.fromFile(File(imagePath)))

        // Create an instance of TextRecognizerOptions
        val textRecognizerOptions = TextRecognizerOptions.Builder().build() // Adjust options as needed
        val textRecognizer = TextRecognition.getClient(textRecognizerOptions)

        // Perform text recognition
        textRecognizer.process(image) // Correct method
                .addOnSuccessListener { text ->
                    Log.d("ScreenshotService", "Detected Text: ${text.text}")
                    sendDetectedTextToFlutter(text.text)
                }
                .addOnFailureListener { e ->
                    Log.e("ScreenshotService", "Text recognition failed", e)
                }
    }

    private fun sendDetectedTextToFlutter(detectedText: String) {
        val flutterEngine = FlutterEngineCache.getInstance().get("my_engine_id")
        if (flutterEngine != null) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("onTextDetected", detectedText)
        } else {
            Log.e("ScreenshotService", "FlutterEngine is not initialized")
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
