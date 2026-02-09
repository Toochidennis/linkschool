package com.linkskool.app

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.linkskool.app/downloads"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    
                    if (fileName != null && bytes != null) {
                        val filePath = saveToDownloads(fileName, bytes)
                        if (filePath != null) {
                            result.success(filePath)
                        } else {
                            result.error("SAVE_FAILED", "Failed to save file to Downloads", null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Invalid arguments provided", null)
                    }
                }
                "openFile" -> {
                    val filePath = call.argument<String>("filePath")
                    
                    if (filePath != null) {
                        val opened = openFile(filePath)
                        if (opened) {
                            result.success(true)
                        } else {
                            result.error("OPEN_FAILED", "Failed to open file", null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Invalid file path", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveToDownloads(fileName: String, bytes: ByteArray): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ (API 29+) - Use MediaStore (no permission needed)
                val resolver = contentResolver
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                }
                
                val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                
                uri?.let {
                    resolver.openOutputStream(it)?.use { outputStream ->
                        outputStream.write(bytes)
                        outputStream.flush()
                    }
                    
                    // Return the URI as string for opening
                    it.toString()
                }
            } else {
                // Android 9 and below (API 28 and below) - Use legacy method
                val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                
                if (!downloadsDir.exists()) {
                    downloadsDir.mkdirs()
                }
                
                val file = File(downloadsDir, fileName)
                
                FileOutputStream(file).use { outputStream ->
                    outputStream.write(bytes)
                    outputStream.flush()
                }
                
                file.absolutePath
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun openFile(filePath: String): Boolean {
        return try {
            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && filePath.startsWith("content://")) {
                // Android 10+ - filePath is actually a content URI
                Uri.parse(filePath)
            } else {
                // Android 9 and below - filePath is a file path
                val file = File(filePath)
                FileProvider.getUriForFile(
                    this,
                    "${applicationContext.packageName}.fileprovider",
                    file
                )
            }

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/pdf")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            // Create chooser to let user select app
            val chooser = Intent.createChooser(intent, "Open with")
            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            startActivity(chooser)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}