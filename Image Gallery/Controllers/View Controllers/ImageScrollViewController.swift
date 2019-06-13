//
//  ImageScrollViewController.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 13.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class ImageScrollViewController: UIViewController {

  // MARK: - Outlets
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var imageView: UIImageView!

  // MARK: - Properties
  var url: URL?
  
  private let minimumZoomScale: CGFloat = 0.1
  private let maximumZoomScale: CGFloat = 3.0
  
  private lazy var fetcher = URLFetcher.shared
  
  // MARK: - View Controller Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let url = url {
      fetcher.fetchImage(from: url) { [weak self] (_, image) in
        guard let self = self else { return }
        DispatchQueue.main.async {
          self.imageView.image = image
          self.imageView.sizeToFit()
          self.scrollView.contentSize = self.imageView.frame.size
          self.scrollView.minimumZoomScale = self.minimumZoomScale
          self.scrollView.maximumZoomScale = self.maximumZoomScale
        }
      }
    }
  }
}

// MARK: - Scroll View Delegate

extension ImageScrollViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
