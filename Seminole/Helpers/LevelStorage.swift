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
    
    /// Загружает уровни из UserDefaults или создает дефолтные
    func loadLevels() -> [LevelModel] {
        if let data = defaults.data(forKey: levelsKey),
           let decodedLevels = try? JSONDecoder().decode([LevelModel].self, from: data) {
            print("Загруженные уровни: \(decodedLevels)")
            return decodedLevels
        } else {
            return createDefaultLevels()
        }
    }
    
    /// Сохраняет уровни в UserDefaults
    func saveLevels(_ levels: [LevelModel]) {
        if let encoded = try? JSONEncoder().encode(levels) {
            defaults.set(encoded, forKey: levelsKey)
            print("Уровни сохранены: \(levels)")
        } else {
            print("Ошибка при кодировании уровней")
        }
    }
    
    /// Обновляет уровень (меняет `isLocked` и количество `stars`) и открывает следующий
    func updateLevel(levelNumber: Int, isLocked: Bool? = nil, stars: Int? = nil) {
        var allLevels = loadLevels()
        
        if let index = allLevels.firstIndex(where: { $0.id == levelNumber }) {
            // Обновляем текущий уровень
            var currentLevel = allLevels[index]
            currentLevel.isLocked = isLocked ?? currentLevel.isLocked
            currentLevel.stars = max(currentLevel.stars ?? 0, stars ?? 0) // Сохраняем лучший результат
            allLevels[index] = currentLevel
            
            // Разблокируем следующий уровень, если он есть
            if index + 1 < allLevels.count {
                var nextLevel = allLevels[index + 1]
                nextLevel.isLocked = false
                allLevels[index + 1] = nextLevel
            }
            
            // Сохраняем обновленный список уровней
            saveLevels(allLevels)
        }
    }
    
    /// Создает уровни по умолчанию (только первый открыт)
    private func createDefaultLevels() -> [LevelModel] {
        let levels = (1...20).map { number in
            LevelModel(number: number, isLocked: number != 1, stars: nil)
        }
        saveLevels(levels)
        return levels
    }
}

/// Модель уровня
struct LevelModel: Identifiable, Codable, Equatable {
    let id: Int
    var isLocked: Bool
    var stars: Int?

    init(number: Int, isLocked: Bool, stars: Int?) {
        self.id = number
        self.isLocked = isLocked
        self.stars = stars
    }
}
