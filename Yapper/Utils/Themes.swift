//
//  Themes.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-16.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class Theme {
    private(set) static var themes: [String: Theme] = ["default": Theme(), "dark": Theme.darkTheme]

    let name: String
    let primary: UIColor
    let primaryDark: UIColor
    let secondary: UIColor
    let secondaryDark: UIColor
    let error: UIColor
    let background: UIColor
    let backgroundText: UIColor
    let text: UIColor
    let textSecondary: UIColor
    let textError: UIColor
    let cornerRadius: CGFloat
    let margin: CGFloat

    private(set) static var currentTheme: Theme = themes[SaveData.shared.theme] ?? Theme()
    private static let name: String = "Default"
    private static let primary: UIColor = UIColor(rgb: 0x007AFF)
    private static let primaryDark: UIColor = UIColor(rgb: 0x004fcb)
    private static let secondary: UIColor = UIColor(rgb: 0x5AC8FA)
    private static let secondaryDark: UIColor = UIColor(rgb: 0x0097c7)
    private static let error: UIColor = UIColor.red
    private static let background: UIColor = UIColor(rgb: 0xF0F0F0)
    private static let backgroundText: UIColor = UIColor.white
    private static let text: UIColor = UIColor.black
    private static let textSecondary: UIColor = UIColor.white
    private static let textError: UIColor = UIColor.white
    private static let cornerRadius: CGFloat = 8
    private static let margin: CGFloat = 8

    init(name: String = name, primary: UIColor = primary, primaryDark: UIColor = primaryDark, secondary: UIColor = secondary, secondaryDark: UIColor = secondaryDark, error: UIColor = error, background: UIColor = background, backgroundText: UIColor = backgroundText, text: UIColor = text, textSecondary: UIColor = textSecondary, textError: UIColor = textError, cornerRadius: CGFloat = cornerRadius, margin: CGFloat = margin) {
        self.name = name
        self.primary = primary
        self.primaryDark = primaryDark
        self.secondary = secondary
        self.secondaryDark = secondaryDark
        self.error = error
        self.background = background
        self.backgroundText = backgroundText
        self.text = text
        self.textSecondary = textSecondary
        self.textError = textError
        self.cornerRadius = cornerRadius
        self.margin = margin
    }
    
    static func setTheme(_ theme: String) {
        guard let newTheme = themes[theme] else { return }
        currentTheme = newTheme
        SaveData.shared.saveTheme(theme)
    }

    static let darkTheme: Theme = Theme(
        name: "Dark",
        primary: UIColor(rgb: 0x5AC8FA),
        primaryDark: UIColor(rgb: 0x0097c7),
        secondary: UIColor(rgb: 0x007AFF),
        secondaryDark: UIColor(rgb: 0x004fcb),
        background: UIColor(rgb: 0x303030),
        backgroundText: UIColor(rgb: 0x101010),
        text: .white,
        textSecondary: .black)
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: Int = 255) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 255, "Invalid alpha component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(Float(alpha) / 255.0))
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(rgba: Int) {
        self.init(
            red: (rgba >> 24) & 0xFF,
            green: (rgba >> 16) & 0xFF,
            blue: (rgba >> 8) & 0xFF,
            alpha: rgba & 0xFF
        )
    }
}
