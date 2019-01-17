//
//  MasterViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-09.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class MasterViewController: UITableViewController {
    private static let TAG = "MasterViewController"

    var detailViewController: DetailViewController? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let yourViewController: LoginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let window = appDelegate.window!
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = yourViewController
                })
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                /*
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                 */
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    @IBAction func actionSignOut(_ sender: Any) {
        DatabaseManager.shared.auth.signOut()
    }
}

