package br.com.gotattoo.app

import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/// Renders a native ad styled to look like a tattoo product card, so it can
/// sit inside the home grid as just another cell.
class NativeAdFactoryImpl(private val layoutInflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView =
            layoutInflater.inflate(R.layout.native_ad_card, null) as NativeAdView

        val media = adView.findViewById<MediaView>(R.id.ad_media)
        adView.mediaView = media

        val headline = adView.findViewById<TextView>(R.id.ad_headline)
        headline.text = nativeAd.headline
        adView.headlineView = headline

        val body = adView.findViewById<TextView>(R.id.ad_body)
        if (nativeAd.body.isNullOrEmpty()) {
            body.visibility = View.GONE
        } else {
            body.visibility = View.VISIBLE
            body.text = nativeAd.body
        }
        adView.bodyView = body

        adView.setNativeAd(nativeAd)
        return adView
    }
}
