import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let nativeConfigChannelName = "app/native_config"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let mapsKey = (Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String) ?? ""
    let trimmedKey = mapsKey.trimmingCharacters(in: .whitespacesAndNewlines)
    let looksUnresolved = trimmedKey.contains("$(GOOGLE_MAPS_API_KEY)") || trimmedKey.contains("$(")
    let mapsConfigured = !trimmedKey.isEmpty && !looksUnresolved
    if mapsConfigured {
      GMSServices.provideAPIKey(trimmedKey)
      print("[MAPS] Google Maps API key configured")
    } else {
      print("[MAPS] Google Maps API key NOT configured (set GOOGLE_MAPS_API_KEY via xcconfig)")
    }

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: nativeConfigChannelName, binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "isGoogleMapsConfigured":
          result(mapsConfigured)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
