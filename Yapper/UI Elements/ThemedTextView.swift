//
//  ThemedTextView.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-10.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ThemedTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        self.textColor = Theme.currentTheme.text
    }
}
