import UIKit
import Flutter
import SwiftUI


class AppDelegate: FlutterAppDelegate, ObservableObject {
    let flutterEngine = FlutterEngine(name: "my flutter engine")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Runs the default Dart entrypoint with a default Flutter route.
            flutterEngine.run();
            // Used to connect plugins (only if you have plugins with iOS platform code).
            GeneratedPluginRegistrant.register(with: self.flutterEngine);
            return true;
        }
}

@main
struct MyApp: App {
    //  Use this property wrapper to tell SwiftUI
    //  it should use the AppDelegate class for the application delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    // Access the AppDelegate using an EnvironmentObject.
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        Button(getButtonName()) {
            openFlutterApp()
        }
    }
    
    func getButtonName() -> String {
        let flutterEngine = FlutterEngine(name: "getButtonName engine")
        
        flutterEngine.run(withEntrypoint: "getButtonName");
                
        var buttonName = ""
        
        let methodChannel = FlutterMethodChannel(name: "com.example/foo", binaryMessenger: flutterEngine.binaryMessenger)
        
        let group = DispatchGroup()
            group.enter()
        
        DispatchQueue.global(qos: .default).async {
            methodChannel.invokeMethod("getButtonName", arguments: nil) { result in
                buttonName = result as? String ?? ""
                group.leave()
            }
        }
        
        group.wait()
        return buttonName
    }
    
    func openFlutterApp() {
        // Get the RootViewController.
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene }) as? UIWindowScene,
            let window = windowScene.windows.first(where: \.isKeyWindow),
            let rootViewController = window.rootViewController
        else { return }
        
        // Create the FlutterViewController.
        let flutterViewController = FlutterViewController(
            // Access the Flutter Engine via AppDelegate.
            engine: appDelegate.flutterEngine,
            nibName: nil,
            bundle: nil)
        flutterViewController.modalPresentationStyle = .overCurrentContext
        flutterViewController.isViewOpaque = false
        
        rootViewController.present(flutterViewController, animated: true)
    }
}

