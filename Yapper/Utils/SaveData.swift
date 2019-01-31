//
//  SaveData.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-31.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

class SaveData {
    static var shared = SaveData()
    private var lastUpdatedCache: [String: Date] = [:]
    
    private init(){
        getAllLastUpdated()
    }

    func update(lastUpdated: Timestamp, forConversation conversation: String) {
        if let lastCached = lastUpdatedCache[conversation], lastCached > lastUpdated.dateValue() {
            return
        }
        self.set(lastUpdated: lastUpdated, forConversation: conversation)
    }
    
    func getLastUpdated(forConversation conversation: String) -> Timestamp? {
        guard let timestamp = lastUpdatedCache[conversation] else { return nil }
        return Timestamp(date: timestamp)
    }

    private func set(lastUpdated: Timestamp, forConversation conversation: String) {
        lastUpdatedCache[conversation] = lastUpdated.dateValue()
        setAllLastUpdated()
    }

    private func getAllLastUpdated() {
        if let temp = UserDefaults.standard.object(forKey: Keys.lastUpdated.rawValue) as? [String: Date] {
            lastUpdatedCache = temp
        }
    }
    
    private func setAllLastUpdated() {
        UserDefaults.standard.set(lastUpdatedCache, forKey: Keys.lastUpdated.rawValue)
    }
    
    private enum Keys: String {
        case lastUpdated = "lastUpdated"
    }
}
