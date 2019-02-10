//
//  ThemeSelectorTableViewCell.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-10.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ThemeSelectorTableViewCell: UITableViewCell {
    @IBOutlet weak var label: ThemedLabel!
    @IBOutlet weak var rounded: RoundedLabel!
    @IBOutlet weak var button: RoundedButton!
    @IBOutlet weak var error: RoundedButton!
    
    var theme: Theme? {
        didSet {
            setTheme()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setTheme() {
        guard let theme = theme else { return }
        self.contentView.backgroundColor = theme.background
        label.text = theme.name
        label.overrideThemeWith(theme: theme)
        rounded.overrideThemeWith(theme: theme)
        button.overrideThemeWith(theme: theme)
        error.overrideThemeWith(theme: theme)
    }
}
