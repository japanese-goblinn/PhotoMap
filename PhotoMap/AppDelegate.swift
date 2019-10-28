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
        
        let tabBarController = UITabBarController()
        let mapViewController = MapViewController()
        let timelineViewController = UINavigationController(
            rootViewController: TimelineViewController()
        )
        timelineViewController.navigationBar.barTintColor = .white
        let moreViewController = MoreViewController()
        
        mapViewController.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "compass"), tag: 0)
        timelineViewController.tabBarItem = UITabBarItem(title: "Timeline", image: #imageLiteral(resourceName: "timeline"), tag: 1)
        moreViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        
        tabBarController.viewControllers = [
            mapViewController,
            timelineViewController,
            moreViewController
        ]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }

}

