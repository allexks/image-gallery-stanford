//
//  ImageGallery.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 11.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import Foundation

class ImageGallery {
  var images: [ImageData] = []
  var title: String?
  
  var count: Int {
    return images.count
  }
  
  init(_ arr: [ImageData] = [], title: String? = nil) {
    images = arr
    self.title = title
  }
  
  subscript(index: Int) -> ImageData {
    return images[index]
  }
}

extension ImageGallery {
  struct ImageData {
    /// The URL of the image.
    var url: URL
    /// The aspect ratio of the image defined as width over height.
    var aspectRatio: Double
  }
}

