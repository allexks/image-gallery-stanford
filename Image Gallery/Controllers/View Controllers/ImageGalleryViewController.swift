//
//  ImageGalleryViewController.swift
//  Image Gallery
//
//  Created by Aleksandar Ignatov on 11.06.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  // MARK: - Properties
  
  private let imageCellReuseIdentifier = "Image Cell"
  private let headerViewReuseIdentifier = "Image Gallery Header"
  private let dropPlaceholderReuseIdentifier = "Drop Placeholder"
  private let itemsPerRow: CGFloat = 3
  private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  
  private lazy var galleries: [ImageGallery] = [ImageGallery([], title: "Dropped")]
  
  private lazy var fetcher = URLFetcher.shared
  
  // MARK: - View Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Helper methods
  private func getImageData(at indexPath: IndexPath) -> ImageGallery.ImageTuple {
    return galleries[indexPath.section][indexPath.row]
  }
  
  private func removeImage(at indexPath: IndexPath) {
    galleries[indexPath.section].images.remove(at: indexPath.row)
  }
  
  private func insertImage(_ tuple: ImageGallery.ImageTuple, at indexPath: IndexPath) {
    galleries[indexPath.section].images.insert(tuple, at: index)
  }
}

// MARK: - Colection View Delegate

extension ImageGalleryViewController: UICollectionViewDelegate {
  // TODO
}

// MARK: - Collection View Data Source

extension ImageGalleryViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return galleries.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int
  ) -> Int {
    return galleries[section].count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseIdentifier,
                                                        for: indexPath) as? ImageCell else {
      return UICollectionViewCell()
    }
    
    cell.backgroundColor = .clear
    let url = getImageData(at: indexPath).url
    fetcher.fetchImage(from: url){ (_, image) in
      DispatchQueue.main.async {
        cell.image.image = image
      }
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath
  ) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerViewReuseIdentifier, for: indexPath) as? ImageGalleryHeader else {
        assert(false, "Could not create collection view header with reuse identifier \"\(headerViewReuseIdentifier)\"")
        //return UICollectionReusableView()
      }
      headerView.label.text = galleries[indexPath.section].title
      return headerView
    default:
      assert(false, "Unexpected collection view element kind: \(kind)")
      //return UICollectionReusableView()
    }
  }
}

// MARK: - Collection View Flow Layout Delegate

extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let itemWidth = (view.frame.width - paddingSpace) / itemsPerRow
    let ratio = getImageData(at: indexPath).aspectRatio
    let itemHeight = itemWidth / CGFloat(ratio)
    
    return CGSize(width: itemWidth, height: itemHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return sectionInsets.left
  }
}

// MARK: - Collection View Drag Delegate

extension ImageGalleryViewController: UICollectionViewDragDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      itemsForBeginning session: UIDragSession,
                      at indexPath: IndexPath
  ) -> [UIDragItem] {
    session.localContext = collectionView
    let image = UIDragItem(itemProvider: NSItemProvider(contentsOf: getImageData(at: indexPath).url)!)
    return [image] // TODO
  }
}

// MARK: - Collection View Drop Delegate

extension ImageGalleryViewController: UICollectionViewDropDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      canHandle session: UIDropSession
  ) -> Bool {
    return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: URL.self)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      dropSessionDidUpdate session: UIDropSession,
                      withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
    let operation: UIDropOperation = (session.localDragSession?.localContext as? UICollectionView) == collectionView ? .move : .copy
    return UICollectionViewDropProposal(operation: operation, intent: .insertAtDestinationIndexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      performDropWith coordinator: UICollectionViewDropCoordinator) {
    let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: galleries[0].count, section: 0)
    
    coordinator.items.forEach { dropItem in
      if let sourceIndexPath = dropItem.sourceIndexPath {
        // local drag n drop
          collectionView.performBatchUpdates({
            let imageData = getImageData(at: sourceIndexPath)
            removeImage(at: sourceIndexPath)
            insertImage(imageData, at: destinationIndexPath)
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
          }, completion: { _ in
            coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
            //collectionView.reloadData()
          })
      } else {
        // drop from outer space
        let placeholder = coordinator.drop(dropItem.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: dropPlaceholderReuseIdentifier))
        dropItem.dragItem.itemProvider.loadObject(ofClass: UIImage.self) {(image, err) in
          guard let image = image as? UIImage,
            err == nil,
            let url = image.storeLocallyAsJPEG(named: String(Date().timeIntervalSinceReferenceDate))
          else {
            DispatchQueue.main.async {
              placeholder.deletePlaceholder()
            }
            print("Error fetching image for destination index path \(destinationIndexPath).")
            return
          }
          let aspectRatio = Double(image.size.width / image.size.height)
          let newImageData = ImageGallery.ImageTuple(url: url, aspectRatio: aspectRatio)
          DispatchQueue.main.async {
            placeholder.commitInsertion { [weak self] indexPath in
              self?.insertImage(newImageData, at: indexPath)
            }
          }
        }
      }
    }
  }
}
