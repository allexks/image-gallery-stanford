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
  
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section != 1
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.section != 1 else { return }
    delegate?.showGallery(getGallery(for: indexPath))
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
    let deleteAction = UITableViewRowAction(style: .destructive,
                                            title: "X") { [weak self] (_, indexPath) in
      guard let self = self else { return }
      tableView.performBatchUpdates({
          self.delegate?.hideGallery(self.getGallery(for: indexPath))
          let newIndexPath = IndexPath(row: self.recentlyDeletedGalleries.endIndex, section: 1)
          self.deleteGallery(at: indexPath)
          if self.recentlyDeletedGalleries.count == 0 {
            tableView.deleteSections(IndexSet(arrayLiteral: 1), with: .automatic)
          }
          if indexPath.section == 0 {
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            if newIndexPath.row == 0 {
              tableView.insertSections(IndexSet(arrayLiteral: 1), with: .automatic)
            }
          }
          tableView.deleteRows(at: [indexPath], with: .automatic)
      }, completion: nil)
    }
    
    var result = [deleteAction]
    
    if indexPath.section == 1 {
      result.append(UITableViewRowAction(style: .normal, title: "Restore") { [weak self] (_, indexPath) in
        guard let self = self else { return }
        tableView.performBatchUpdates({
          let newIndexPath = IndexPath(row: self.savedGalleries.endIndex, section: 0)
          self.undeleteGallery(at: indexPath)
          if self.recentlyDeletedGalleries.count == 0 {
            tableView.deleteSections(IndexSet(arrayLiteral: 1), with: .automatic)
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
  
  private func deleteGallery(at indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      recentlyDeletedGalleries.append(getGallery(for: indexPath))
      savedGalleries.remove(at: indexPath.row)
    case 1:
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
