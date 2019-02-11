//
//  InfoViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-11.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class InfoViewController: ThemedViewController {
    @IBOutlet weak var infoTextField: ThemedTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        infoTextField.text = NSLocalizedString("infoText", comment: "This application was developed in six weeks as a student assignment in Application Development Continuation course at Newton Vocational College.\n\nJonas Theslöf, 2019\nhttp://github.com/theslof")
    }
}
