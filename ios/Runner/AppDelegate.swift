import Flutter
import GoogleMaps
import UIKit
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Provide Google Maps API key from Info.plist if present
    // Support two Info.plist keys: `GOOGLE_MAPS_API_KEY` (preferred) and `GMSServicesAPIKey` (older key)
    let apiKey = (Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String)
      ?? (Bundle.main.object(forInfoDictionaryKey: "GMSServicesAPIKey") as? String)
    if let googleMapsApiKey = apiKey, !googleMapsApiKey.isEmpty {
      GMSServices.provideAPIKey(googleMapsApiKey)
    } else {
      NSLog("[AppDelegate] WARNING: Google Maps API key not found in Info.plist. Add `GOOGLE_MAPS_API_KEY` or `GMSServicesAPIKey`.")
    }

    // Plugins are registered by Flutter; Firebase is initialized in Dart
    GeneratedPluginRegistrant.register(with: self)
    
    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if granted {
            print("✅ Notification permission granted")
          } else {
            print("❌ Notification permission denied")
          }
        }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle APNs token registration
  override func application(_ application: UIApplication, 
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ APNs token registered: \(deviceToken)")
    // Firebase will automatically handle this token
  }
  
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error)")
  }
}
