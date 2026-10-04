package io.github.jcosmith.foodie

import android.app.LocaleManager
import android.os.Build
import android.os.LocaleList
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "io.github.jcosmith.foodie/application_language",
        ).setMethodCallHandler { call, result ->
            // The per-app language setting exists from Android 13 (API 33).
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val localeManager = getSystemService(LocaleManager::class.java)
            when (call.method) {
                "readApplicationLanguage" -> {
                    val locales = localeManager.applicationLocales
                    result.success(if (locales.isEmpty()) "" else locales.get(0).language)
                }
                "writeApplicationLanguage" -> {
                    val languageCode = call.argument<String>("languageCode").orEmpty()
                    localeManager.applicationLocales =
                        if (languageCode.isEmpty()) {
                            LocaleList.getEmptyLocaleList()
                        } else {
                            LocaleList.forLanguageTags(languageCode)
                        }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
