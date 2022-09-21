//
//  QOTDViewController.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/17/22.
//

import Foundation
import CoreData
import UIKit

class QOTDViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.quote_download_queue")
    
    @IBOutlet weak var QOTDLabel: UILabel!
    @IBOutlet weak var QOTDAuthorLabel: UILabel!
    
    var quotes: Quote!
    var savedQuotes: SavedQuotes!
    var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var fetchedResultsController: NSFetchedResultsController<Quote>!
    
    func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Quote> = Quote.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "authorName", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.getQOTD() { response, error in
            debugPrint("\(String(describing: response)) was returned")
            if error == nil {
                let responseText = response?[0]
                self.QOTDLabel.text = responseText?.text
                self.QOTDAuthorLabel.text = responseText?.author
            }
        }
    }
    
    @IBAction func GetQuotesButton(_ sender: Any) {
        setupFetchedResultsController()
        guard fetchedResultsController.fetchedObjects?.count ?? 0 < 5 else { return }
        NetworkManager.getQuotes { quoteResponse, error in
            try? self.dataController.viewContext.save()
        }
    }
}


