//
//  URLFetcher.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 12.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class URLFetcher {
  static let shared = URLFetcher()
  private init() {}
  
  func fetchImage(from url: URL, handler: @escaping (URL, UIImage) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      if let data = try? Data(contentsOf: url.imageURL),
         let image = UIImage(data: data)
      {
        handler(url, image)
        return
      }
      
      print("Fetch failed.")
      let image = UIImage(imageLiteralResourceName: "question-mark")
      let url = image.storeLocallyAsJPEG(named: String(Date().timeIntervalSinceReferenceDate))!
      handler(url, image)
    }
  }
}
