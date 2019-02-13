//
//  ThemeSelectionTableViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-10.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ThemeSelectionTableViewController: ThemedTableViewController {
    
    let themes: [String] = Array(Theme.themes.keys)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Theme.themes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ThemeSelectorTableViewCell ?? ThemeSelectorTableViewCell()
        cell.theme = Theme.themes[themes[indexPath.row]]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Theme.setTheme(themes[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
