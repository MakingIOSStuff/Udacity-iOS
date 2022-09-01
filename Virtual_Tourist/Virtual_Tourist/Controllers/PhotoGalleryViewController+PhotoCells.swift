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
        let pin = Pin(context: dataController.viewContext)
        return storedPhotos ? pin.pics!.count : pin.links!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCells", for: indexPath) as! ImageCells
        useStoredImagesOrURLs(storedPhotos: storedPhotos, indexPath, cell: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = ImageURL() as NSManagedObject
        dataController.viewContext.delete(url)
        let photo = Photo() as NSManagedObject
        dataController.viewContext.delete(photo)
        collectionView.deleteItems(at: [indexPath])
    }
    
    fileprivate func useStoredImagesOrURLs(storedPhotos: Bool, _ indexPath: IndexPath, cell: ImageCells ) {
        switch storedPhotos {
        case false:
            let imageUrl = ImageURL(context: dataController.viewContext) as ImageURL
            // Setup cells
            cell.imageView.image = UIImage(systemName: "photo.fill")
            cell.activityIndicator.startAnimating()
            if let url = imageUrl.url { FlickrClient.getPhotosFromStore(url: url) { data, error in
                if let data = data {
                    let image = UIImage(data: data)
                    cell.imageView.image = image
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    let pictures = Photo(context: self.dataController.viewContext)
                    pictures.picture = data
                    self.pin.addToPics(pictures)
                    self.saveContext()
                    self.saveData()
                }
            }
            }
        case true:
            let pictures = pin.pics?.anyObject() as! Photo
            DispatchQueue.main.async {
                if pictures.picture != nil {
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    //Configure cell
                    cell.imageView.image = UIImage()
                }
            }
        }
    }
    
    fileprivate func saveData() {
        if self.pin.pics!.count < 15 {return} else {self.storedPhotos = true}
        self.collectionView.reloadData()
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

