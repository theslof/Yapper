//
//  RoundedLabel.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-22.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class RoundedLabel: UIView {
    private let size: CGFloat
    
    var label: ThemedLabel = ThemedLabel(frame: .zero)

    var text: String? {
        get {
            return self.label.text
        }
        set {
            self.label.text = newValue
        }
    }

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
        self.addSubview(label)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 1.5
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: self.size),
            label.widthAnchor.constraint(equalTo: label.heightAnchor)
            ])
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = Theme.currentTheme.secondaryDark
        label.textColor = Theme.currentTheme.textSecondary
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isOpaque = true
        label.textAlignment = .center
        
        label.clipsToBounds = true
        label.layer.borderWidth = 2
        label.layer.borderColor = Theme.currentTheme.background.cgColor

        label.layer.cornerRadius = self.size / 2
        prepareForInterfaceBuilder()
    }
}
