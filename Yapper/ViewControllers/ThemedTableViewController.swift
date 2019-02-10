//
//  ThemedTableViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-10.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ThemedTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.backgroundColor = Theme.currentTheme.background
    }

    // MARK: - Table view data source
}
