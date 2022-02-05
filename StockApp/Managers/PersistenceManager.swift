//
//  PersistenceManager.swift
//  StockApp
//
//  Created by Kirill Fedin on 08.01.2022.
//

import Foundation

// ["AAPL", "MSFT", "SNAP"]
// [APPL: Apple Inc.]

final class PersistenceManager {
    static let shared = PersistenceManager()
    private init() {}
    
    private let userDefault: UserDefaults = .standard
    
    private struct C {
        static let onboardedKey = "hasOnboarded"
        static let watchListKey = "watchList"
    }
    
    // MARK: - Public
    public var watchList: [String] {
        if !hasOnboarded {
            userDefault.setValue(true, forKey: C.onboardedKey)
            setupDefaultCompanies()
        }
        return userDefault.stringArray(forKey: C.watchListKey) ?? []
    }
    
    public func watchListContains(symbol: String) -> Bool {
        return watchList.contains(symbol)
    }
    
    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchList
        current.append(symbol)
        
        userDefault.set(current, forKey: C.watchListKey)
        userDefault.set(companyName, forKey: symbol)
        
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    public func removeFromWatchList(symbol: String) {
        var newList = [String]()
        userDefault.set(nil, forKey: symbol)
        
        for item in watchList where item != symbol {
            newList.append(item)
        }
        
        userDefault.set(newList, forKey: C.watchListKey)
    }
    // MARK: - Private
    private var hasOnboarded: Bool {
        return userDefault.bool(forKey: C.onboardedKey)
    }
    
    private func setupDefaultCompanies() {
        let map: [String: String] = [
            "AAPL": "Apple Inc.",
            "SNAP": "Snap Inc.",
            "MSFT": "Microsoft Corporation",
            "AMZN": "Amazon.com Inc.",
            "WORK": "Slack Technologies",
            "FB": "Facebook Inc.",
            "GOOG": "Alphabet",
            "NVDA": "Nvidia Inc.",
            "NKE": "Nike",
            "PINS": "Pinterest"
        ]
        
        let symbols = map.keys.map { $0 }
        userDefault.set(symbols, forKey: C.watchListKey)
        
        for (symbol, name) in map {
            userDefault.set(name, forKey: "\(symbol)")
        }
    }
}
