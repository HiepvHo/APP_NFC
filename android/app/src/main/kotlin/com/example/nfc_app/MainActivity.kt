package com.example.nfc_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.nfc.NfcAdapter
import android.nfc.NfcManager
import android.content.Context
import android.app.Activity
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app_settings"
    private val TAG = "NFCApp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "nfc" -> {
                    try {
                        val nfcManager = context.getSystemService(Context.NFC_SERVICE) as? NfcManager
                        if (nfcManager == null) {
                            Log.d(TAG, "NFC Manager is null")
                            result.error("NFC_ERROR", "NFC Manager không khả dụng", null)
                            return@setMethodCallHandler
                        }

                        val nfcAdapter = nfcManager.defaultAdapter
                        if (nfcAdapter == null) {
                            Log.d(TAG, "NFC Adapter is null")
                            result.error("NFC_NOT_SUPPORTED", "Thiết bị không hỗ trợ NFC", null)
                            return@setMethodCallHandler
                        }

                        if (!nfcAdapter.isEnabled) {
                            Log.d(TAG, "NFC is disabled, opening settings")
                            try {
                                val intent = Intent(Settings.ACTION_NFC_SETTINGS)
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                context.startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error opening NFC settings: ${e.message}")
                                result.error("SETTINGS_ERROR", "Không thể mở cài đặt NFC: ${e.message}", null)
                            }
                        } else {
                            Log.d(TAG, "NFC is enabled")
                            result.success(false)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error checking NFC: ${e.message}")
                        result.error("NFC_ERROR", "Lỗi khi kiểm tra NFC: ${e.message}", null)
                    }
                }
                else -> {
                    Log.d(TAG, "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }
}