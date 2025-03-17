//
//  ShopStorage.swift
//  Seminole
//
//  Created by Pavel Ivanov on 17.03.2025.
//

import Foundation

final class ShopStorage {
    
    static let shared = ShopStorage()
    
    private init() {}
    
    private let defaults = UserDefaults.standard
    private let skinKey = "storedLevels"
    private let sphereKey = "storedLevels"

    func loadSkinId() -> String {
        if let decodedSkin = defaults.string(forKey: skinKey) {
            return decodedSkin
        } else {
            saveSkinId("skin1")
            return "skin1"
        }
    }

    func saveSkinId(_ id: String) {
        defaults.set(id, forKey: skinKey)
    }
    
    func loadSphereId() -> String {
        if let decodedSkin = defaults.string(forKey: skinKey) {
            return decodedSkin
        } else {
            saveSphereId("sphere1")
            return "sphere1"
        }
    }

    func saveSphereId(_ id: String) {
        defaults.set(id, forKey: skinKey)
    }
}
