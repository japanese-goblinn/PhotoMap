//
//  Coordinator.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 11/2/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import Firebase

class Coordinator {

    static func showMainApplication(from vc: UIViewController) {
        
        let tabBarController = UITabBarController()
        
//        let mapViewController = UINavigationController(
//            rootViewController: MapViewController()
//        )
        let mapViewController = MapViewController()
        
        let timelineViewController = UINavigationController(
            rootViewController: TimelineViewController()
        )
        timelineViewController.navigationBar.barTintColor = .white
        
        let moreViewController = MoreViewController()
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            moreViewController.currentUser = user
        }
        
        mapViewController.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "compass"), tag: 0)
        timelineViewController.tabBarItem = UITabBarItem(title: "Timeline", image: #imageLiteral(resourceName: "timeline"), tag: 1)
        moreViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
               
        tabBarController.viewControllers = [
            mapViewController,
            timelineViewController,
            moreViewController
        ]
        tabBarController.modalPresentationStyle = .fullScreen
        vc.present(tabBarController, animated: true)
    }
}
