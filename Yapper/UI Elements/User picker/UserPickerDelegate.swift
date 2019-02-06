//
//  UserPickerDelegate.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-06.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation

protocol UserPickerDelegate {
    func userPicker(_ userPicker: UserPickerViewController, didFinishPickingUsersWithUsers users: [String])
}
