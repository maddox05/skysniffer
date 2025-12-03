import SwiftUI
import UIKit
import SuperwallKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Superwall.configure(apiKey: Config.superwallAPIKey)
        return true
    }
}
