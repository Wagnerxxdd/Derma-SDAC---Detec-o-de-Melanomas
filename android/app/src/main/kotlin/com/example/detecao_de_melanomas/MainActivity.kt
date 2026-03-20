package com.example.detecao_de_melanomas

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.detecao_de_melanomas/photos"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveImageToGallery") {
                val path = call.argument<String>("path")
                if (path != null) {
                    val saved = saveImageToGallery(path)
                    if (saved) result.success(true) else result.error("ERROR", "Não foi possível salvar", null)
                } else {
                    result.error("ERROR", "Caminho nulo", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(path: String): Boolean {
        try {
            val file = File(path)
            val inputStream = FileInputStream(file)
            val filename = file.name

            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, filename)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/MelanomaApp")
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }
            }

            val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: return false

            val outputStream: OutputStream? = contentResolver.openOutputStream(uri)
            outputStream?.use { it.write(inputStream.readBytes()) }
            inputStream.close()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                values.clear()
                values.put(MediaStore.Images.Media.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
            }

            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }
}
