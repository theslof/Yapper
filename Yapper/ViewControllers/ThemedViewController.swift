//
//  ThemedViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-06.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ThemedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.currentTheme.background
    }
}
