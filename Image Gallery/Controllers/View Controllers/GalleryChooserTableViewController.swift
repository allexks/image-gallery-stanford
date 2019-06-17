//
//  GalleryChooserTableViewController.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 13.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

protocol GalleryChooserTableViewControllerDelegate: class {
  func showGallery(_ gallery: ImageGallery)
  func hideGallery(_ gallery: ImageGallery)
  func renameGallery(_ gallery: ImageGallery, with newName: String)
}

class GalleryChooserTableViewController: UITableViewController {
  
  // MARK: - Properties
  
  private let galleryCellReusableIdentifier = "Image Gallery Cell"
  
  private let defaultNewGalleryName = "New Gallery"
  
  private let savedGalleriesIndexPathSection = 0
  private let savedGalleriesHeader = "Image Galleries"
  private let recentlyDeletedIndexPathSection = 1
  private let recentlyDeletedHeader = "Recently Deleted"
  
  private(set) var savedGalleries: [ImageGallery] = []
  private(set) var recentlyDeletedGalleries: [ImageGallery] = []
  
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
    case savedGalleriesIndexPathSection:
      return savedGalleries.count
    case recentlyDeletedIndexPathSection:
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
    case savedGalleriesIndexPathSection:
      return savedGalleriesHeader
    case recentlyDeletedIndexPathSection:
      return recentlyDeletedHeader
    default:
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section != recentlyDeletedIndexPathSection
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.section != recentlyDeletedIndexPathSection else { return }
    delegate?.showGallery(getGallery(for: indexPath))
    // Note: The following code is a fix for compact width devices
    if let galleryVC = delegate as? ImageGalleryViewController,
      let rightNavCtrl = galleryVC.navigationController {
      splitViewController?.showDetailViewController(rightNavCtrl, sender: nil)
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
  
  override func tableView(_ tableView: UITableView,
                          editActionsForRowAt indexPath: IndexPath
    ) -> [UITableViewRowAction]? {
    let deleteAction = UITableViewRowAction(style: .destructive, title: "X") { [weak self] (_, indexPath) in
      guard let self = self else { return }
      tableView.performBatchUpdates({
        self.delegate?.hideGallery(self.getGallery(for: indexPath))
        let newIndexPathIfMoveIntoRecentlyDeleted = IndexPath(row: self.recentlyDeletedGalleries.endIndex,
                                     section: self.recentlyDeletedIndexPathSection)
        self.deleteGallery(at: indexPath)
        if self.recentlyDeletedGalleries.count == 0 {
          tableView.deleteSections(IndexSet(arrayLiteral: self.recentlyDeletedIndexPathSection), with: .automatic)
        }
        if indexPath.section == self.savedGalleriesIndexPathSection {
          tableView.insertRows(at: [newIndexPathIfMoveIntoRecentlyDeleted], with: .automatic)
          if newIndexPathIfMoveIntoRecentlyDeleted.row == 0 {
            tableView.insertSections(IndexSet(arrayLiteral: self.recentlyDeletedIndexPathSection), with: .automatic)
          }
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
      }, completion: nil)
    }
    
    var result = [deleteAction]
    
    if indexPath.section == recentlyDeletedIndexPathSection {
      result.append(UITableViewRowAction(style: .normal, title: "Restore") { [weak self] (_, indexPath) in
        guard let self = self else { return }
        tableView.performBatchUpdates({
          let newIndexPath = IndexPath(row: self.savedGalleries.endIndex, section: self.savedGalleriesIndexPathSection)
          self.undeleteGallery(at: indexPath)
          if self.recentlyDeletedGalleries.count == 0 {
            tableView.deleteSections(IndexSet(arrayLiteral: self.recentlyDeletedIndexPathSection), with: .automatic)
          }
          tableView.deleteRows(at: [indexPath], with: .automatic)
          tableView.insertRows(at: [newIndexPath], with: .automatic)
        }, completion: nil)
      })
    }
    
    return result
  }
  
  // MARK: - Helper methods
  
  private func getGallery(for indexPath: IndexPath) -> ImageGallery {
    switch indexPath.section {
    case savedGalleriesIndexPathSection:
      return savedGalleries[indexPath.row]
    case recentlyDeletedIndexPathSection:
      return recentlyDeletedGalleries[indexPath.row]
    default:
      assert(false, "No gallery associated with indexPath \(indexPath)")
    }
  }
  
  private func addImageGallery(_ newGallery: ImageGallery) {
    rename(newGallery, to: newGallery.title)
    savedGalleries.append(newGallery)
    tableView.reloadData()
  }
  
  private func rename(_ gallery: ImageGallery, to name: String?) {
    var newTitle = name ?? defaultNewGalleryName
    newTitle = newTitle.madeUnique(withRespectTo: (savedGalleries + recentlyDeletedGalleries).compactMap { $0.title })
    
    if gallery.title != newTitle {
      delegate?.renameGallery(gallery, with: newTitle)
      gallery.title = newTitle
    }
  }
  
  private func deleteGallery(at indexPath: IndexPath) {
    switch indexPath.section {
    case savedGalleriesIndexPathSection:
      recentlyDeletedGalleries.append(getGallery(for: indexPath))
      savedGalleries.remove(at: indexPath.row)
    case recentlyDeletedIndexPathSection:
      recentlyDeletedGalleries.remove(at: indexPath.row)
    default:
      return
    }
  }
  
  private func undeleteGallery(at indexPath: IndexPath) {
    savedGalleries.append(getGallery(for: indexPath))
    recentlyDeletedGalleries.remove(at: indexPath.row)
  }
}

// MARK: - Text Field Delegate

extension GalleryChooserTableViewController: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let cell = textField.superview?.superview as? GalleryCell,
      let indexPath = tableView.indexPath(for: cell) else {
        return
    }
    
    rename(getGallery(for: indexPath), to: textField.text)
    textField.isEnabled = false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
