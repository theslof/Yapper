//
//  RoundedButton.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-16.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    private func commonInit() {
        self.layer.cornerRadius = Theme.currentTheme.cornerRadius
        self.layer.backgroundColor = Theme.currentTheme.primary.cgColor
        self.setTitleColor(Theme.currentTheme.text, for: .normal)
    }
}
