//
//  ThemedLabel.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-06.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ThemedLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTheme()
    }
    
    private func setTheme() {
        self.textColor = Theme.currentTheme.text
    }
}
