//
//  PhotoGalleryViewController+PhotoCells.swift
//  Virtual_Tourist
//
//  Created by Joel Gans on 8/28/22.
//

import Foundation
import UIKit
import CoreData

extension PhotoGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.pics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        setupFetchedResultsController()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCells", for: indexPath) as! ImageCells
        setupFetchedResultsController()
        debugPrint("Sending photo to cell")
        useStoredImagesOrURLs(storedPhotos: storedPhotos, indexPath, cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let url = pin.pics.url.object(at: indexPath.item) as! NSManagedObject
//        dataController.viewContext.delete(url)
        let photo = pin.pics?.object(at: indexPath.item) as! NSManagedObject
        dataController.viewContext.delete(photo)
        collectionView.deleteItems(at: [indexPath])
    }
    
    func useStoredImagesOrURLs(storedPhotos: Bool, _ indexPath: IndexPath,_ cell: ImageCells ) {
        debugPrint("StoredOrURL")
        self.saveData()
        switch storedPhotos {
        case false:
            let imageUrl = fetchedResultsController.object(at: indexPath)
            // Setup cells
            cell.imageView.image = UIImage(systemName: "photo.fill")
            cell.activityIndicator.startAnimating()
            if let url = imageUrl.url { FlickrClient.getPhotosFromStore(url: url) { data, error in
                if let data = data {
                    let image = UIImage(data: data)
                    debugPrint("Set the images to the collection view")
                    cell.imageView.image = image
                    cell.activityIndicator.stopAnimating()
                    let pictures = Photo(context: self.dataController.viewContext)
                    pictures.picture = data
                    self.pin.addToPics(pictures)
                    self.saveContext()
                    self.saveData()
                }
            }
            }
        case true:
            debugPrint("Found photos in store, send to collectionview")
            let pictures = pin.pics?.object(at: indexPath.item) as! Photo
            DispatchQueue.main.async {
                if let data = pictures.picture {
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    //Configure cell
                    cell.imageView.image = UIImage(data: data)
                }
            }
        }
        debugPrint("Sent the pics to cells")
    }
    
    
    func saveData() {
        if self.pin.pics!.count < 10 {
            self.storedPhotos = false
            return
            
        } else {
            self.storedPhotos = true}
//        self.collectionView.reloadData()
    }
    func saveContext() {
        try? dataController.viewContext.save()
    }
    func deletingObjectsFromCoreData(objects: NSOrderedSet) {
        let context = dataController.viewContext
        
        for object in objects {
            context.delete(object as! NSManagedObject)
        }
    }
}

