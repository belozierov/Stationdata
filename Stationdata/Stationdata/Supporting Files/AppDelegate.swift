//
//  AppDelegate.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private let window = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //rootViewController
        window.rootViewController = UINavigationController(rootViewController: ListViewController())
        window.makeKeyAndVisible()
        
        return true
    }

}
