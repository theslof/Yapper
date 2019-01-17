//
//  Log.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-17.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation

struct Log {
    private init() {}
    
    static func d(_ TAG: String, _ message: String) {
        #if DEBUG
        debugPrint("\(TAG): \(message)")
        #endif
    }
    
    static func e(_ TAG: String, _ message: String) {
        #if DEBUG
        debugPrint("\(TAG): \(message)")
        #endif
    }
    
    static func i(_ TAG: String, _ message: String) {
        #if DEBUG
        print("\(TAG): \(message)")
        #endif
    }
    
}
