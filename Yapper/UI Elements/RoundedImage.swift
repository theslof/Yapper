//
//  RoundImage.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-21.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class RoundedImage: UIView {
    private var imageView: UIImageView?
    private var size: CGFloat = 44
    
    var image: UIImage? {
        get {
            return self.imageView?.image
        }
        set {
            self.imageView?.image = newValue
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = self.frame.width / 2
        }
    }

    init(frame: CGRect, size: CGFloat) {
        super.init(frame: frame)
        self.size = size
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let imageView = UIImageView(frame: self.frame)
        self.imageView = imageView
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.image = UIImage(named: "placeholder")!

        self.clipsToBounds = true
        self.layer.cornerRadius = size / 2
        self.layer.borderWidth = 2
        self.layer.borderColor = Theme.currentTheme.backgroundText.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = Theme.currentTheme.text.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 1.5
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
    }
}
