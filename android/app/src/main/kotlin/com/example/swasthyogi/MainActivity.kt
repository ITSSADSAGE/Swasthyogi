package com.example.swasthyogi

import android.telephony.SmsManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "swasthyogi/sms"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val phone = call.argument<String>("phone")
                val message = call.argument<String>("message")
                
                if (phone != null && message != null) {
                    try {
                        val smsManager: SmsManager = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                            this.getSystemService(SmsManager::class.java).createForSubscriptionId(SmsManager.getDefaultSmsSubscriptionId())
                        } else if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                            this.getSystemService(SmsManager::class.java)
                        } else {
                            SmsManager.getDefault()
                        }
                        
                        val parts = smsManager.divideMessage(message)
                        smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
                        
                        android.widget.Toast.makeText(this, "SOS SMS sent to $phone", android.widget.Toast.LENGTH_SHORT).show()
                        result.success(true)
                    } catch (e: Exception) {
                        println("SMS Native Error: ${e.message}")
                        android.widget.Toast.makeText(this, "SMS Failed: ${e.message}", android.widget.Toast.LENGTH_LONG).show()
                        result.error("SMS_FAILED", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Phone or message is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
