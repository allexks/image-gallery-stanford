//
//  GalleryChooserTableViewController.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 13.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

protocol GalleryChooserTableViewControllerDelegate: class {
  func selectGallery(_ gallery: ImageGallery)
  func deselectGallery(_ gallery: ImageGallery)
  func renameGallery(_ gallery: ImageGallery, with newName: String)
}

class GalleryChooserTableViewController: UITableViewController {
  
  // MARK: - Properties
  
  let galleryCellReusableIdentifier = "Image Gallery Cell"
  let defaultNewGalleryName = "New Gallery"
  
  var savedGalleries: [ImageGallery] = []
  var recentlyDeletedGalleries: [ImageGallery] = []
  
  weak var delegate: GalleryChooserTableViewControllerDelegate?
  
  // MARK: - Actions
  
  @IBAction func onTapAddButton(_ sender: UIBarButtonItem) {
    addImageGallery(ImageGallery([], title: nil))
  }
  
  // MARK: - Table View Delegate and Data Source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return recentlyDeletedGalleries.isEmpty ? 1 : 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return savedGalleries.count
    case 1:
      return recentlyDeletedGalleries.count
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: galleryCellReusableIdentifier) as? GalleryCell else {
      print("Could not load cell at indexPath \(indexPath)")
      return UITableViewCell()
    }
    
    cell.textField.text = getGallery(for: indexPath).title
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Image Galleries"
    case 1:
      return "Recently Deleted"
    default:
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.selectGallery(getGallery(for: indexPath))
  }
  
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    delegate?.deselectGallery(getGallery(for: indexPath))
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
  
  // MARK: - Helper methods
  
  private func getGallery(for indexPath: IndexPath) -> ImageGallery {
    switch indexPath.section {
    case 0:
      return savedGalleries[indexPath.row]
    case 1:
      return recentlyDeletedGalleries[indexPath.row]
    default:
      fatalError("No gallery associated with indexPath \(indexPath)")
    }
  }
  
  
  private func addImageGallery(_ newGallery: ImageGallery) {
    rename(newGallery, to: newGallery.title)
    savedGalleries.append(newGallery)
    tableView.reloadData()
  }
  
  private func rename(_ gallery: ImageGallery, to name: String?) {
    var newTitle = name ?? defaultNewGalleryName
    newTitle = newTitle.madeUnique(withRespectTo: (savedGalleries + recentlyDeletedGalleries).filter{ $0.title != nil }.map { $0.title! })
    
    if gallery.title != newTitle {
      delegate?.renameGallery(gallery, with: newTitle)
      gallery.title = newTitle
    }
  }
}
