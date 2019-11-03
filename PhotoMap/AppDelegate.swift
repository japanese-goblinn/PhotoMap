//
//  AppDelegate.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/1/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
//        Database.database().isPersistenceEnabled = true
        
        let loginVC = LoginViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = loginVC
        window?.makeKeyAndVisible()
        return true
    }

}

