# Tesseract4Android / Leptonica: native code reads private fields (mNativeData,
# mNativePix...) and calls back into Java (onProgressValues) through JNI, and
# the AAR ships no consumer rules. Keep these classes unchanged under R8.
-keep class com.googlecode.tesseract.android.** { *; }
-keep class com.googlecode.leptonica.android.** { *; }
