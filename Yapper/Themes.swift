//
//  Themes.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-16.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class Theme {
    let primary: UIColor
    let primaryDark: UIColor
    let secondary: UIColor
    let secondaryDark: UIColor
    let error: UIColor
    let background: UIColor
    let text: UIColor
    let textSecondary: UIColor
    let textError: UIColor
    let cornerRadius: CGFloat
    
    static var currentTheme: Theme = defaultTheme
    private static let primary: UIColor = UIColor(rgb: 0x007AFF)
    private static let primaryDark: UIColor = UIColor(rgb: 0x004fcb)
    private static let secondary: UIColor = UIColor(rgb: 0x5AC8FA)
    private static let secondaryDark: UIColor = UIColor(rgb: 0x0097c7)
    private static let error: UIColor = UIColor.red
    private static let background: UIColor = UIColor.white
    private static let text: UIColor = UIColor.white
    private static let textSecondary: UIColor = UIColor.black
    private static let textError: UIColor = UIColor.white
    private static let cornerRadius: CGFloat = 8

    init(primary: UIColor = primary, primaryDark: UIColor = primaryDark, secondary: UIColor = secondary, secondaryDark: UIColor = secondaryDark, error: UIColor = error, background: UIColor = background, text: UIColor = text, textSecondary: UIColor = textSecondary, textError: UIColor = textError, cornerRadius: CGFloat = cornerRadius) {
        self.primary = primary
        self.primaryDark = primaryDark
        self.secondary = secondary
        self.secondaryDark = secondaryDark
        self.error = error
        self.background = background
        self.text = text
        self.textSecondary = textSecondary
        self.textError = textError
        self.cornerRadius = cornerRadius
    }
}

extension Theme {
    static let defaultTheme: Theme = Theme()
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
