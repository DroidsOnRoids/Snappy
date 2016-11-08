//
//  AppDelegate.swift
//  Snappy
//
//  Created by Lukasz Mroz on 13.03.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let left = storyboard.instantiateViewController(withIdentifier: "left")
        let middle = storyboard.instantiateViewController(withIdentifier: "middle")
        let right = storyboard.instantiateViewController(withIdentifier: "right")
        let top = storyboard.instantiateViewController(withIdentifier: "top")
        let snapContainer = SnapContainerViewController.containerViewWith(left, middleVC: middle, rightVC: right, topVC: top)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = snapContainer
        window?.makeKeyAndVisible()
        
        return true
    }
}

