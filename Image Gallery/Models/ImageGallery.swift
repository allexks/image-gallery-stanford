//
//  ImageGallery.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 11.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import Foundation

class ImageGallery {
  typealias ImageTuple = (url: URL, aspectRatio: Double)
  
  var images: [ImageTuple] = []
  var title: String?
  
  var count: Int {
    return images.count
  }
  
  init(_ arr: [ImageTuple] = [], title: String? = nil) {
    images = arr
    self.title = title
  }
  
  subscript(index: Int) -> ImageTuple {
    return images[index]
  }
}
