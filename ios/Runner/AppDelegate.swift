import Flutter
import FirebaseCore
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    
    // Initialize Google Maps SDK
    // Get API key from Info.plist
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let plist = NSDictionary(contentsOfFile: path),
       let apiKey = plist["GMSApiKey"] as? String,
       !apiKey.isEmpty && apiKey != "YOUR_IOS_GOOGLE_MAPS_API_KEY" {
      GMSServices.provideAPIKey(apiKey)
    } else {
      // Use placeholder key to prevent crash (maps won't work but app won't crash)
      // In production, this should be a valid key from Google Cloud Console
      GMSServices.provideAPIKey("AIzaSyBruEqo9VBO82RYUtRzbS00_t97taO2T2Y")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
