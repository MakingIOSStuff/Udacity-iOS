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
        setupFetchedResultsController()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCells", for: indexPath) as! ImageCells
        photo = pin.pics?.object(at: indexPath.row) as? Photo
        debugPrint("photo contains: \(String(describing: photo))")
        if photo.picture != nil {
                debugPrint("photo.pic data is: \(String(describing: self.photo.picture))")
                debugPrint("Try to set the cell")
            if let data = photo.picture {
                    DispatchQueue.main.async() {
                        cell.imageView.image = UIImage(data: data)
                    }
                }
        } else {
            if let url = photo.url {
            downloadImage(imagePath: url.absoluteString) { imageData, error in
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: imageData!)
            }
            }
        }
        }
        debugPrint("Sending photo to cell")
        return cell
    }
    
    func downloadImage( imagePath: String, completionHandler: @escaping (_ imageData: Data?, _ error: String?) -> Void) {
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest (url: imgURL! as URL)
        let task = session.dataTask(with: request as URLRequest) { data, response, downloadError in
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                completionHandler(data, nil)
            }
            self.photo.picture = data
            self.saveContext()
        }
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = pin.pics?.object(at: indexPath.item) as! NSManagedObject
        dataController.viewContext.delete(photo)
        collectionView.deleteItems(at: [indexPath])
        saveContext()
        setupFetchedResultsController()
    }
    
    func useStoredImagesOrURLs(_ indexPath: IndexPath,_ cell: ImageCells, completion: @escaping (Data?, Error?) -> ())  {
        debugPrint("StoredOrURL")
        if photo.picture == nil {
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
                                cell.activityIndicator.stopAnimating()
                                debugPrint("The photos should be coming destination")
                                DispatchQueue.main.async {
                                    completion(data, nil)
                                }
                            } else {
                                cell.activityIndicator.stopAnimating()
                                debugPrint("Failed to send photos")
                                DispatchQueue.main.async {
                                    completion(nil, error)
                                }
                            }
                        }
                    }
                } else {
                    cell.activityIndicator.stopAnimating()
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        } else {
            debugPrint("Found photos in store, send to collectionview")
            let photo = self.pin.pics?.object(at: indexPath.item) as! Photo
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
        guard ((fetchedResultsController.fetchedObjects?.isEmpty) != nil) else { return }
        fetchedResultsController.fetchedObjects?.forEach { (photo) in
            dataController.viewContext.delete(photo)
        }
        saveContext()
    }
}
