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
        overrideThemeWith(theme: Theme.currentTheme)
    }
    
    func overrideThemeWith(theme: Theme) {
        if error {
            self.layer.backgroundColor = theme.error.cgColor
            self.setTitleColor(theme.textError, for: .normal)
        } else {
            self.layer.backgroundColor = theme.primary.cgColor
            self.setTitleColor(theme.text, for: .normal)
        }
        self.layer.cornerRadius = theme.cornerRadius
    }

}
