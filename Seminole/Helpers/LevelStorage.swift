//
//  LevelStorage.swift
//  Seminole
//
//  Created by Pavel Ivanov on 16.03.2025.
//

import Foundation

final class LevelStorage {
    
    static let shared = LevelStorage()
    
    private init() {}
    
    private let defaults = UserDefaults.standard
    private let levelsKey = "storedLevels"
    
    // Загрузка данных из UserDefaults или инициализация дефолтного состояния
    func loadLevels() -> [LevelModel] {
        if let data = defaults.data(forKey: levelsKey),
           let decodedLevels = try? JSONDecoder().decode([LevelModel].self, from: data) {
            return decodedLevels
        } else {
            return createDefaultLevels()
        }
    }
    
    // Сохранение уровней в UserDefaults
    func saveLevels(_ levels: [LevelModel]) {
        if let encoded = try? JSONEncoder().encode(levels) {
            defaults.set(encoded, forKey: levelsKey)
        }
    }
    
    // Обновление конкретного уровня (разблокировка или изменение звезд)
    func updateLevel(_ levelNumber: Int, isLocked: Bool? = nil, stars: Int? = nil) {
        var levels = loadLevels()
        if let index = levels.firstIndex(where: { $0.number == levelNumber }) {
            let currentLevel = levels[index]
            levels[index] = LevelModel(
                number: currentLevel.number,
                isLocked: isLocked ?? currentLevel.isLocked,
                stars: stars ?? currentLevel.stars
            )
            saveLevels(levels)
        }
    }
    
    // Создание дефолтных уровней (все закрыты, кроме первого)
    private func createDefaultLevels() -> [LevelModel] {
        let levels = (1...20).map { number in
            LevelModel(number: number, isLocked: number != 1, stars: nil)
        }
        saveLevels(levels)
        return levels
    }
}
