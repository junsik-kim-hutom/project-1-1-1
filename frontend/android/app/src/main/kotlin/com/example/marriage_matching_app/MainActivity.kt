package com.example.marriage_matching_app

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val nativeConfigChannelName = "app/native_config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nativeConfigChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isGoogleMapsConfigured" -> {
                        try {
                            val appInfo = packageManager.getApplicationInfo(
                                packageName,
                                PackageManager.GET_META_DATA
                            )
                            val rawKey =
                                appInfo.metaData?.getString("com.google.android.geo.API_KEY") ?: ""
                            val trimmed = rawKey.trim()
                            val looksUnresolved = trimmed.contains("\${") || trimmed.contains("$(")
                            val configured = trimmed.isNotEmpty() && !looksUnresolved
                            result.success(configured)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "getGoogleMapsApiKey" -> {
                        try {
                            val appInfo = packageManager.getApplicationInfo(
                                packageName,
                                PackageManager.GET_META_DATA
                            )
                            val rawKey =
                                appInfo.metaData?.getString("com.google.android.geo.API_KEY") ?: ""
                            val trimmed = rawKey.trim()
                            val looksUnresolved = trimmed.contains("\${") || trimmed.contains("$(")
                            val configured = trimmed.isNotEmpty() && !looksUnresolved
                            result.success(if (configured) trimmed else null)
                        } catch (e: Exception) {
                            result.success(null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
