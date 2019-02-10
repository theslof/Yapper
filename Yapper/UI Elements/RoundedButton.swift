//
//  RoundedButton.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-16.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: ThemedButton {

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
