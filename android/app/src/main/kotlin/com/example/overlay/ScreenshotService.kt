package com.example.overlay

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.DisplayMetrics
import android.view.WindowManager
import android.widget.Toast
import androidx.core.app.NotificationCompat
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions

class ScreenshotService : Service() {

    private val CHANNEL_ID = "screenshot_service_channel"
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private lateinit var imageReader: ImageReader

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(1, createNotification())

        val mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val resultCode = intent?.getIntExtra("resultCode", Activity.RESULT_OK)
        val data = intent?.getParcelableExtra<Intent>("data")

        if (resultCode != null && data != null) {
            mediaProjection = mediaProjectionManager.getMediaProjection(resultCode, data)
            startCapture()
        }

        return START_NOT_STICKY
    }

    private fun createNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelName = "Screenshot Service"
            val channel = NotificationChannel(
                CHANNEL_ID, channelName,
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Taking Screenshot")
            .setContentText("The app is capturing a screenshot.")
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .build()
    }

    private fun startCapture() {
        // Registering the MediaProjection callback first
        mediaProjection?.registerCallback(object : MediaProjection.Callback() {
            override fun onStop() {
                super.onStop()
                // Clean up resources here when the MediaProjection is stopped
                virtualDisplay?.release()
                imageReader.close()
                mediaProjection = null
                stopSelf() // Stop the service when the projection is stopped
            }
        }, Handler(Looper.getMainLooper()))

        // Get the display metrics after registering the callback
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val metrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(metrics)

        val width = metrics.widthPixels
        val height = metrics.heightPixels
        val density = metrics.densityDpi

        // Create ImageReader for capturing screenshots
        imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)

        // Now create the virtual display
        virtualDisplay = mediaProjection?.createVirtualDisplay(
                "ScreenCapture",
                width,
                height,
                density,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                imageReader.surface,
                null,
                Handler(Looper.getMainLooper())
        )

        // Set an ImageAvailableListener to process the captured image
        imageReader.setOnImageAvailableListener({ reader ->
            val image = reader.acquireLatestImage()
            if (image != null) {
                val planes = image.planes
                val buffer = planes[0].buffer
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

                // Start OCR process with the captured bitmap
                processImageForOCR(bitmap)
            }
        }, Handler(Looper.getMainLooper()))
    }


    private fun saveScreenshot(bitmap: Bitmap) {
        // Here you can modify to save the screenshot image to storage
        // Example: Save to file and send the file path back to Flutter for OCR
        Toast.makeText(this, "Screenshot taken!", Toast.LENGTH_SHORT).show()
        stopSelf()
    }

    private fun processImageForOCR(bitmap: Bitmap) {
        val image = InputImage.fromBitmap(bitmap, 0)
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

        recognizer.process(image)
                .addOnSuccessListener { textResult ->
                    handleTextRecognitionResult(textResult)
                }
                .addOnFailureListener { e ->
                    Toast.makeText(this, "Text recognition failed: ${e.message}", Toast.LENGTH_SHORT).show()
                    stopSelf()
                }
    }

    private fun handleTextRecognitionResult(result: Text) {
        val detectedText = result.text
        Toast.makeText(this, "Detected text: $detectedText", Toast.LENGTH_LONG).show()
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        virtualDisplay?.release()
        mediaProjection?.stop()
        imageReader.close()
    }
}
