import CoreGraphics

let levels: [[CellModel]] = [
    // Level 1 - Легкий старт, игрок обучается
    [
        CellModel(type: .normal, owner: .player, health: 20, position: CGPoint(x: 150, y: 500)),
        CellModel(type: .normal, owner: .neutral, health: 5, position: CGPoint(x: 300, y: 300)),
        CellModel(type: .normal, owner: .enemy, health: 10, position: CGPoint(x: 200, y: 400)),
    ],
    
    // Level 2 - Добавление врага
    [
        CellModel(type: .normal, owner: .player, health: 25, position: CGPoint(x: 100, y: 500)),
        CellModel(type: .normal, owner: .neutral, health: 5, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .normal, owner: .enemy, health: 15, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .attack, owner: .enemy, health: 10, position: CGPoint(x: 300, y: 200)),
    ],
    
    // Level 3 - Первый серьезный вызов
    [
        CellModel(type: .attack, owner: .player, health: 30, position: CGPoint(x: 100, y: 500)),
        CellModel(type: .defense, owner: .neutral, health: 10, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .normal, owner: .enemy, health: 25, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .attack, owner: .enemy, health: 20, position: CGPoint(x: 300, y: 200)),
    ],
    
    // Level 4 - Нейтральные клетки стратегически важны
    [
        CellModel(type: .attack, owner: .player, health: 35, position: CGPoint(x: 120, y: 500)),
        CellModel(type: .multiplier, owner: .neutral, health: 15, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .attack, owner: .enemy, health: 20, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .defense, owner: .enemy, health: 25, position: CGPoint(x: 200, y: 600)),
        CellModel(type: .normal, owner: .enemy, health: 15, position: CGPoint(x: 300, y: 350)),
    ],
    
    // Level 5 - Враг становится агрессивнее
    [
        CellModel(type: .normal, owner: .player, health: 40, position: CGPoint(x: 100, y: 500)),
        CellModel(type: .normal, owner: .neutral, health: 10, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .attack, owner: .enemy, health: 35, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .normal, owner: .enemy, health: 20, position: CGPoint(x: 200, y: 600)),
        CellModel(type: .defense, owner: .enemy, health: 30, position: CGPoint(x: 300, y: 500)),
    ],
    
    // Level 6 - Добавляем сложность, враг умнее
    [
        CellModel(type: .attack, owner: .player, health: 50, position: CGPoint(x: 100, y: 500)),
        CellModel(type: .normal, owner: .enemy, health: 40, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .attack, owner: .enemy, health: 30, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .multiplier, owner: .neutral, health: 15, position: CGPoint(x: 200, y: 600)),
        CellModel(type: .defense, owner: .enemy, health: 25, position: CGPoint(x: 300, y: 450)),
    ],
    
    // Level 7 - Битва за центр
    [
        CellModel(type: .attack, owner: .player, health: 50, position: CGPoint(x: 150, y: 500)),
        CellModel(type: .defense, owner: .enemy, health: 50, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .attack, owner: .enemy, health: 30, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .multiplier, owner: .neutral, health: 20, position: CGPoint(x: 200, y: 600)),
        CellModel(type: .attack, owner: .enemy, health: 30, position: CGPoint(x: 400, y: 100)),
        CellModel(type: .normal, owner: .enemy, health: 20, position: CGPoint(x: 300, y: 200)),
    ],
    
    // Level 8 - Враг получает бонусы
    [
        CellModel(type: .attack, owner: .player, health: 50, position: CGPoint(x: 100, y: 500)),
        CellModel(type: .normal, owner: .enemy, health: 50, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .attack, owner: .enemy, health: 40, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .multiplier, owner: .neutral, health: 20, position: CGPoint(x: 200, y: 600)),
        CellModel(type: .multiplier, owner: .enemy, health: 30, position: CGPoint(x: 400, y: 200)),
        CellModel(type: .defense, owner: .enemy, health: 25, position: CGPoint(x: 300, y: 350)),
    ],

    // Level 9 - Игрок должен использовать стратегию
    [
        CellModel(type: .attack, owner: .player, health: 60, position: CGPoint(x: 150, y: 500)),
        CellModel(type: .normal, owner: .enemy, health: 60, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .attack, owner: .enemy, health: 50, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .multiplier, owner: .neutral, health: 30, position: CGPoint(x: 200, y: 600)),
        CellModel(type: .attack, owner: .enemy, health: 40, position: CGPoint(x: 300, y: 200)),
    ],

    // Level 10 - Большая битва
    [
        CellModel(type: .attack, owner: .player, health: 80, position: CGPoint(x: 150, y: 500)),
        CellModel(type: .normal, owner: .enemy, health: 70, position: CGPoint(x: 250, y: 400)),
        CellModel(type: .attack, owner: .enemy, health: 60, position: CGPoint(x: 350, y: 300)),
        CellModel(type: .defense, owner: .neutral, health: 50, position: CGPoint(x: 200, y: 600)),
        CellModel(type: .multiplier, owner: .enemy, health: 40, position: CGPoint(x: 400, y: 200)),
        CellModel(type: .attack, owner: .enemy, health: 50, position: CGPoint(x: 300, y: 350)),
    ],

    // Level 11-20 - Повышаем сложность, рандомизируем уровни
    (11...20).map { level in
        var cells: [CellModel] = [
            CellModel(type: .attack, owner: .player, health: 80, position: CGPoint(x: 150, y: 500)),
            CellModel(type: .normal, owner: .enemy, health: 70, position: CGPoint(x: 250, y: 400)),
            CellModel(type: .attack, owner: .enemy, health: 60, position: CGPoint(x: 350, y: 300)),
        ]
        
        // Добавляем больше врагов и нейтральных
        for _ in 1...(level / 2 + 1) {
            cells.append(CellModel(type: .defense, owner: .enemy, health: Int.random(in: 40...80), position: CGPoint(x: Int.random(in: 100...400), y: Int.random(in: 200...600))))
        }
        for _ in 1...(level / 3 + 1) {
            cells.append(CellModel(type: .multiplier, owner: .neutral, health: Int.random(in: 20...50), position: CGPoint(x: Int.random(in: 100...400), y: Int.random(in: 200...600))))
        }
        return cells
    }
].flatMap { $0 }
