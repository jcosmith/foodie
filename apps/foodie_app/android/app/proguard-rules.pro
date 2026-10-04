# Receipt scanning bundles only ML Kit's Latin text model. The plugin also
# references the Chinese, Devanagari, Japanese and Korean models, which the
# app leaves out on purpose, so R8 must not fail on their missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
