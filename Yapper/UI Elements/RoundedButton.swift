//
//  RoundedButton.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-16.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

@IBDesignable
open class RoundedButton: UIButton {
    @IBInspectable var error: Bool = false {
        didSet {
            setStyle()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setStyle()
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setStyle()
    }

    private func setStyle() {
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
