//
//  ThemedButton.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-06.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ThemedButton: UIButton {
    @IBInspectable var error: Bool = false {
        didSet {
            setTheme()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTheme()
    }
    
    private func setTheme() {
        if error {
            self.layer.backgroundColor = Theme.currentTheme.error.cgColor
            self.setTitleColor(Theme.currentTheme.textError, for: .normal)
        } else {
            self.layer.backgroundColor = Theme.currentTheme.primary.cgColor
            self.setTitleColor(Theme.currentTheme.text, for: .normal)
        }
        self.layer.cornerRadius = Theme.currentTheme.cornerRadius
    }
}
