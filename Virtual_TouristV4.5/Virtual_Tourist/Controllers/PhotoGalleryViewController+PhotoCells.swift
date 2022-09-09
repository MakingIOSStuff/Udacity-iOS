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
        return pin.pics?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        setupFetchedResultsController()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCells", for: indexPath) as! ImageCells
        if self.collectionView.numberOfItems(inSection: 0) < 15 {
            debugPrint("No items for cells, get some items for cells now.")
            useStoredImagesOrURLs(indexPath, cell) { data, error in
                guard let data = data, error == nil else { return }
                if let data = self.photo.picture {
                    debugPrint("Try to set the cell")
                    DispatchQueue.main.async() {
                        cell.imageView.image = UIImage(data: data)
                    }
                }
                debugPrint("the data returned was \(String(describing: data))")
            }
        }
        debugPrint("Sending photo to cell")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        let url = pin.pics.url.object(at: indexPath.item) as! NSManagedObject
        //        dataController.viewContext.delete(url)
        let photo = pin.pics?.object(at: indexPath.item) as! NSManagedObject
        dataController.viewContext.delete(photo)
        collectionView.deleteItems(at: [indexPath])
    }
    
    func useStoredImagesOrURLs(_ indexPath: IndexPath,_ cell: ImageCells, completion: @escaping (Data?, Error?) -> ())  {
        debugPrint("StoredOrURL")
        if pin.pics == nil {
            debugPrint("no stored photos, get new ones")
            let imageUrl = fetchedResultsController.object(at: indexPath)
            cell.imageView.image = UIImage(systemName: "photo.fill")
            cell.activityIndicator.startAnimating()
            FlickrClient.requestPhotos(latitude: pin.latitude, longitude: pin.longitude) { response, error in
                if let response = response {
                    debugPrint("The photoRequest returned: \(response)")
                    response.photos.photo.forEach { FlickrPhoto in
                        FlickrClient.getPhotosFromServer(server: FlickrPhoto.server, id: FlickrPhoto.id, secret: FlickrPhoto.secret) { data, error in
                            if data == data {
                                debugPrint("The photos should be coming destination")
                                DispatchQueue.main.async {
                                    completion(data, nil)
                                }
                            } else {
                                debugPrint("Failed to send photos")
                                DispatchQueue.main.async {
                                    completion(nil, error)
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        } else {
            debugPrint("Found photos in store, send to collectionview")
            let pictures = self.pin.pics?.object(at: indexPath.item) as! Photo
            DispatchQueue.main.async {
                if let url = self.photo.url { FlickrClient.getPhotosFromStore(url: url) { data, error in
                    if let data = data {
                        debugPrint("The data returned from true case: \(String(describing: data))")
                        let image = UIImage(data: data)
                        debugPrint("Set the images to the collection view")
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                        let pictures = Photo(context: self.dataController.viewContext)
                        pictures.picture = data
                        self.pin.addToPics(pictures)
                        DispatchQueue.main.async {
                            completion(data, nil)
                        }
                    }
                }
                }
                debugPrint("Sent the pics to cells")
            }
        }
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
