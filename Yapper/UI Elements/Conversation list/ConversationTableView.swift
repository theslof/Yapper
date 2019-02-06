//
//  ConversationTableView.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-21.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ConversationTableView: UITableView {
    override init(frame: CGRect, style: Style) {
        super.init(frame: frame, style: style)
        setTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTheme()
    }

    private func setTheme() {
        self.backgroundColor = Theme.currentTheme.background
    }
}
