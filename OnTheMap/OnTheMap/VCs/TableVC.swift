//
//  TableVC.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import Foundation
import UIKit

class UITableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentList()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: TableView Setup
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")!
        let student = StudentArray.students[indexPath.row]
        let mediaURL = StudentArray.students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName ?? "") \(student.lastName ?? "")"
        cell.detailTextLabel?.text = "\(mediaURL)"
        return cell
    }
    
    //MARK: TableViewRowCount
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentArray.students.count
    }
    
    //MARK: TableViewRowSelected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentArray.students[indexPath.row]
        if let mediaURL = URL(string: student.mediaURL ?? "") {
            UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
        }
    }
    private func getStudentList() {
        UdacityClient.getAllStudentLocationsWithLimit(limit: 100, completion: { (results, error) in
            if let results = results {
                StudentArray.students = results
                self.tableView.reloadData()
            } else {
                self.showError(message: error!.localizedDescription)
            }
        })
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    @IBAction func refreshButtonPress(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        UdacityClient.logout { ( success, error) in
            if success {
                self.presentingViewController?.dismiss(animated: true, completion:  nil)
            } else {
                self.showError(message: error!.localizedDescription)
            }
        }
        
    }
}



