import Flutter
import UIKit
import flutter_background_service_ios

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // FlutterBackgroundService の初期化
    FlutterBackgroundServicePlugin.initialize()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}