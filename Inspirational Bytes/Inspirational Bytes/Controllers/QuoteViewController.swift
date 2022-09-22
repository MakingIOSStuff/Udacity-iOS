//
//  QuoteViewController.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/11/22.
//

import UIKit
import CoreData

class QuoteViewController: UIViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var QuoteLabel: UILabel!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var favButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var refreshQuoteButton: UIButton!
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.quote_download_queue")
    var favQuoteText: String = ""
    var author: String = ""
    var fromFavorites: Bool = false
    var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var quote: Quote!
    var savedQuotes: SavedQuotes!
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
        if fetchedResultsController.fetchedObjects!.count == 0 {
            debugPrint("Did not find stored quotes. Sending for more.")
            NetworkManager.getQuotes { [self] quoteResponse, error in
                if error == nil {
                    let index = (Int.random(in: 1...20))
                    let currentQuote = quoteResponse?[index]
                    self.QuoteLabel.text = currentQuote?.text
                    self.AuthorLabel.text = currentQuote?.author
                    try? self.dataController.viewContext.save()
                    self.setupFetchedResultsController()
                    self.activityIndicator.stopAnimating()
                    let quote = Quote(context: self.dataController.viewContext)
                    }
                }
        } else {
            debugPrint("Found stored. Get Random Quote")
            let index = (Int.random(in: 1...(fetchedResultsController.fetchedObjects?.count)!))
            let currentQuote = fetchedResultsController.fetchedObjects?[index]
            QuoteLabel.text = currentQuote?.quoteText
            AuthorLabel.text = currentQuote?.authorName
            activityIndicator.stopAnimating()
        }
        try? dataController.viewContext.save()
    }
    
    @IBAction func NewQuoteButton(_ sender: Any) {
        activityIndicator.startAnimating()
        setSavedQuote()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    func createShareQuote() -> UIImage {
        backButton.customView?.isHidden = true
        favButton.customView?.isHidden = true
        shareButton.customView?.isHidden = true
        refreshQuoteButton.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let shareQuote: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        backButton.customView?.isHidden = false
        favButton.customView?.isHidden = false
        shareButton.customView?.isHidden = false
        refreshQuoteButton.isHidden = false
        
        return shareQuote
    }
    
    @IBAction func saveToFav(_ sender: Any) {
        savedQuotes.quoteText = QuoteLabel.text
        savedQuotes.authorName = AuthorLabel.text
        debugPrint("Saving items to savedquotes")
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let shareQuote = createShareQuote()
        let controller = UIActivityViewController(activityItems: [shareQuote], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}

