//
//  QuoteViewController.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/11/22.
//

import UIKit
import CoreData

class QuoteViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var QuoteLabel: UILabel!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.quote_download_queue")
    var favQuoteText: String = ""
    var author: String = ""
    var fromFavorites: Bool = false
    var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var quote: Quote!
    var fetchedResultsController: NSFetchedResultsController<Quote>!
    
    fileprivate func setupFetchedResultsController() {
        
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
        setupFetchedResultsController()
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }

    override func viewWillAppear(_ animated: Bool) {
        if fromFavorites {
            QuoteLabel.text = favQuoteText
            AuthorLabel.text = author
            activityIndicator.stopAnimating()
        } else {
            setSavedQuote()
        }
    }
    
    func setSavedQuote() {
        guard fetchedResultsController.fetchedObjects?.count ?? 0 < 5 else { return }
        NetworkManager.getQuotes { quoteResponse, error in
            if quoteResponse != nil {
                self.quote.authorImage = quoteResponse?.image
                self.quote.authorName = quoteResponse?.author
                self.quote.htmlString = quoteResponse?.html
                self.quote.quoteText = quoteResponse?.text
                self.quote.count = quoteResponse?.count
            }
            self.QuoteLabel.text = self.quote.quoteText
            self.AuthorLabel.text = self.quote.authorName
        }
        
    }
    
    @IBAction func NewQuoteButton(_ sender: Any) {
        dataController.viewContext.delete(quote)
        try? dataController.viewContext.save()
        reloadInputViews()
        activityIndicator.startAnimating()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}

