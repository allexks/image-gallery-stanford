//
//  GalleryCell.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 13.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class GalleryCell: UITableViewCell {
  
  // MARK: - Outlets
  
  @IBOutlet weak var textField: UITextField!
  
  // MARK: - Properties
  
  var tapGestureRecognizer: UITapGestureRecognizer!
  
  // MARK: - Methods
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapCell(_:)))
    tapGestureRecognizer.numberOfTapsRequired = 2
    addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc private func onDoubleTapCell(_ sender: UIGestureRecognizer) {
    textField.isEnabled = true
  }
}
