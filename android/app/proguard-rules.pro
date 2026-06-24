# flutter_stripe: the Stripe Android SDK references push-provisioning classes
# that aren't bundled (they're an optional add-on). Don't let R8 fail on them,
# and keep the SDK classes so reflection-based payment flows work in release.
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }
