//
//  RoundImage.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-21.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImage: UIImageView {
    private let size: CGFloat
    
    init(frame: CGRect, size: CGFloat) {
        self.size = size
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.size = 44
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.clipsToBounds = true
        self.layer.cornerRadius = size / 2
        self.layer.borderWidth = 2
        self.layer.borderColor = Theme.currentTheme.background.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 1.5
        self.layer.shadowOffset = CGSize(width: -1.5, height: 1.5)
        prepareForInterfaceBuilder()
    }
}
