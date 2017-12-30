//
//  AppDelegate.swift
//  DaydreamSample
//
//  Created by Sachin on 2/2/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var viewController: DiscoveryViewController?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		viewController = DiscoveryViewController()
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = UIColor.white
		window?.rootViewController = viewController
		window?.makeKeyAndVisible()
		
		return true
	}
}
