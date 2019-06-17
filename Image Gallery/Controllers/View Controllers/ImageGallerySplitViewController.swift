//
//  ImageGallerySplitViewController.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 17.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class ImageGallerySplitViewController: UISplitViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let leftNavigationController = viewControllers.first as? UINavigationController,
      let masterVC = leftNavigationController.topViewController as? GalleryChooserTableViewController,
      let rightNavigationController = viewControllers.last as? UINavigationController,
      let detailVC = rightNavigationController.topViewController as? ImageGalleryViewController else {
        assert(false, "View controllers relationships not set correctly!")
    }
    
    masterVC.delegate = detailVC
    
    detailVC.navigationItem.leftItemsSupplementBackButton = true
    detailVC.navigationItem.leftBarButtonItem = displayModeButtonItem
  }
}
