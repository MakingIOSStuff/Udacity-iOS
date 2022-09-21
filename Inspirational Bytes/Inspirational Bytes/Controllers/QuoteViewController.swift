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
        if fetchedResultsController.fetchedObjects?.count ?? 0 < 5 {
            NetworkManager.getQuotes { quoteResponse, error in
                if error == nil {
                    var currentQuote = quoteResponse[0]
                    self.QuoteLabel.text = currentQuote.text
                    self.AuthorLabel.text = currentQuote.author
                    try? self.dataController.viewContext.save()
                    self.setupFetchedResultsController()
                }
            }
        } else {
            var currentQuote = fetchedResultsController.fetchedObjects?[0]
            QuoteLabel.text = currentQuote?.quoteText
            AuthorLabel.text = currentQuote?.authorName
        }
        activityIndicator.stopAnimating()
    }
    
    @IBAction func NewQuoteButton(_ sender: Any) {
        guard let item = fetchedResultsController.fetchedObjects?[0] else { return }
        dataController.viewContext.delete(item)
        try? dataController.viewContext.save()
        reloadInputViews()
        activityIndicator.startAnimating()
        setSavedQuote()
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

