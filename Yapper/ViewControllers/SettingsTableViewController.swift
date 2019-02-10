//
//  SettingsTableViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-08.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableViewController: ThemedTableViewController {
    
    private let rows: [String] = ["theme", "info", "signout"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.visibleCells.forEach { cell in
            cell.backgroundColor = Theme.currentTheme.background
            cell.contentView.subviews.forEach({ view in
                if let view = view as? ThemedLabel {
                    view.overrideThemeWith(theme: Theme.currentTheme)
                }
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case "theme":
            performSegue(withIdentifier: "themeSelectorViewController", sender: self)
        case "info":
            performSegue(withIdentifier: "infoViewController", sender: self)
        case "signout":
            do {
                try Auth.auth().signOut()
            } catch let error {
                Log.e("Settings", error.localizedDescription)
            }
        default:
            break
        }
    }
}
