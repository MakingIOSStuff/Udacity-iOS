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
    
    private func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let pin = Pin(context: dataController.viewContext)
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCells", for: indexPath) as! ImageCells
//        useStoredImagesOrURLs(storedPhotos: storedPhotos, indexPath, cell: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = ImageURL() as NSManagedObject
        dataController.viewContext.delete(url)
        let photo = Photo() as NSManagedObject
        dataController.viewContext.delete(photo)
        collectionView.deleteItems(at: [indexPath])
    }
    
    func useStoredImagesOrURLs(storedPhotos: Bool, _ indexPath: IndexPath, cell: ImageCells ) {
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
//                    self.saveData()
                }
            }
            }
        case true:
//            let pictures = pin.pics?.object(at: indexPath.item) as! Photo
//            setupFetchedResultsController()
//            let imagePics = fetchedResultsController.object(at: indexPath)
//            if pin.links == imagePics.links {
//                if pin.pics == imagePics.pics {
//                    cell.imageView.image = UIImage(imagePics)
//                }
//            }
            //            fetchedResultsController.fetchedObjects?.forEach( { pics in
            //                let pictures = pin.pics
            //            })
            DispatchQueue.main.async {
                //                if let data = pictures {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.isHidden = true
                //Configure cell
                cell.imageView.image = UIImage()
            }
        }
    }

    
//    func getPhotosFromStore(images: [String]) {
//        images.forEach { (pics) in
//            pin.pics = pics
//            dataController.viewContext.insert(photo)
//            try? dataController.viewContext.save()
//        }
//    }
    
//    func saveData() {
////        if self.pin.pics!.count < 15 {return} else {self.storedPhotos = true}
//        self.collectionView.reloadData()
//    }
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

