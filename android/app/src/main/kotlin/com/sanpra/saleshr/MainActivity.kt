package com.sanpra.saleshr

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {

    private val CHANNEL = "whatsapp_sender"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "sendPdfWhatsApp") {

                    val filePath = call.argument<String>("filePath")
                    val phone = call.argument<String>("phone")
                    val message = call.argument<String>("message")

                    try {
                        val file = File(filePath!!)

                        val uri: Uri = FileProvider.getUriForFile(
                            this,
                            applicationContext.packageName + ".provider",
                            file
                        )

                        val intent = Intent(Intent.ACTION_SEND)
                        intent.type = "application/pdf"
                        intent.putExtra(Intent.EXTRA_STREAM, uri)
                        intent.putExtra(Intent.EXTRA_TEXT, message)

                        /// 🔥 JID
                        intent.putExtra("jid", "$phone@s.whatsapp.net")

                        intent.setPackage("com.whatsapp")
                        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

                        startActivity(intent)

                        result.success("sent")

                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
            }
    }
}