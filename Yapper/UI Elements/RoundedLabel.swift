//
//  RoundedLabel.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-22.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class RoundedLabel: UIView {
    var label: UILabel?
    var text: String? {
        get {
            return self.label?.text
        }
        set {
            self.label?.text = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.label = UILabel(frame: self.frame)
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 1.5
        self.layer.shadowOffset = CGSize(width: -1.5, height: 1.5)
        
        if let label = label {
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = Theme.currentTheme.secondaryDark
            label.textColor = Theme.currentTheme.textSecondary
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.isOpaque = true
            label.textAlignment = .center

            self.addSubview(label)
            label.clipsToBounds = true
            label.layer.cornerRadius = self.layer.frame.size.height / 2
            label.layer.borderWidth = 2
            label.layer.borderColor = Theme.currentTheme.background.cgColor
        }

        prepareForInterfaceBuilder()
    }
}
