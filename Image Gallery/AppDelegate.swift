//
//  AppDelegate.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 11.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    guard let splitVC = window?.rootViewController as? UISplitViewController,
      let leftNavigationController = splitVC.viewControllers.first as? UINavigationController,
      let masterVC = leftNavigationController.topViewController as? GalleryChooserTableViewController,
      let rightNavigationController = splitVC.viewControllers.last as? UINavigationController,
      let detailVC = rightNavigationController.topViewController as? ImageGalleryViewController else {
        assert(false, "View controllers relationships not set correctly in application(didFinishLaunchingWithOptions:)")
    }
    
    masterVC.delegate = detailVC
    
    return true
  }
}

