//
//  AppDelegate.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices
import IQKeyboardManagerSwift
import FBSDKCoreKit
import DropDown


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        self.clearBadgeNumber()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay ]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self.getNotificationSettings()
            }
        } else {
            // REGISTER FOR PUSH NOTIFICATIONS
            let notifTypes:UIUserNotificationType  = [.alert, .badge, .sound]
            let settings = UIUserNotificationSettings(types: notifTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.applicationIconBadgeNumber = 0
        }
        
        application.registerForRemoteNotifications()
        
        Global_SetGlassEffect()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        DropDown.startListeningToKeyboard()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //AudioServicesPlayAlertSound(1110)
        SoundManager.shared.playMessageSound()
        
        if let pushType = userInfo["Type"] as? String {
            
            if pushType == PushNotificationType.message {//push notification for message
             
                if application.applicationState == .inactive || application.applicationState == .background {
                    USERDEFAULTS.set(userInfo["userId"], forKey: lc_senderId)
                    USERDEFAULTS.synchronize()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.displayMessage), object: nil, userInfo: userInfo)
                
            } else {// push notification for chat request
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.chatRequest), object: nil, userInfo: userInfo)
            }
        }
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        return handled
        
//        return FBAppCall.handleOpen(url, sourceApplication: "")
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        self.clearBadgeNumber()
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func clearBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()
    }
}
    // [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.setValue(fcmToken, forKey: "token")

    }

//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("Received data message: \(remoteMessage.appData)")
//    }
}
