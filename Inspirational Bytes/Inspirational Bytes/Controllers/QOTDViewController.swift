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
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Quote>!
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Quote> = Quote.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "author", ascending: false)
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
            guard response != nil else { return }
            self.QOTDLabel.text = response?.text
            self.QOTDAuthorLabel.text = response?.author
        }
    }
    
    
    @IBAction func GetQuotesButton(_ sender: Any) {
        setupFetchedResultsController()
        guard fetchedResultsController.fetchedObjects?.count ?? 0 < 5 else { return }
        NetworkManager.getQuotes { quoteResponse, error in
            if quoteResponse != nil {
                self.savedQuotes.authorImage = quoteResponse?.image
                self.savedQuotes.authorName = quoteResponse?.author
                self.savedQuotes.htmlString = quoteResponse?.html
                self.savedQuotes.quoteText = quoteResponse?.text
                self.savedQuotes.count = quoteResponse?.count
            }
        }
    }
    
    
}


