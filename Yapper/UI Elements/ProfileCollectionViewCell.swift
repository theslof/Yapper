//
//  ProfileCollectionViewCell.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-12.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: RoundedImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
    }
    
    override func prepareForReuse() {
        commonInit()
    }
}
