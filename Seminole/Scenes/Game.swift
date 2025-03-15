import SwiftUI

// MARK: - Типы клеток
enum CellType {
    case normal
    case attack
    case defense
    case multiplier
}

// MARK: - Владельцы клеток
enum CellOwner {
    case player
    case enemy
    case neutral
}

// MARK: - Модель клетки
class CellModel: Identifiable, Equatable {
    static func == (lhs: CellModel, rhs: CellModel) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    let type: CellType
    var owner: CellOwner
    var health: Double
    var position: CGPoint
    
    // Максимальное количество соединений
    var maxConnections: Int = 2
    var currentConnections: Int = 0
    
    init(type: CellType, owner: CellOwner, health: Double, position: CGPoint, maxConnections: Int = 2, currentConnections: Int = 0) {
        self.type = type
        self.owner = owner
        self.health = health
        self.position = position
        self.maxConnections = maxConnections
        self.currentConnections = currentConnections
    }
}

// MARK: - Модель связи (щупальца)
class TentacleConnection: Identifiable {
    let id = UUID()
    
    var sourceCellID: UUID
    var targetCellID: UUID
    
    var owner: CellOwner  // кто создаёт связь
    var progress: Double
    var strength: Double
    
    init(sourceCellID: UUID, targetCellID: UUID, owner: CellOwner, progress: Double = 0, strength: Double = 1) {
        self.sourceCellID = sourceCellID
        self.targetCellID = targetCellID
        self.owner = owner
        self.progress = progress
        self.strength = strength
    }
}

// MARK: - Результат игры
enum GameResultType {
    case none
    case win
    case lose
}

// MARK: - Класс логики
class GameLogic {
    unowned let state: GameState
    
    // Базовые скорости
    let baseAttackSpeed = 0.5
    let baseTransferSpeed = 0.5
    let baseHealSpeed = 0.3
    
    init(state: GameState) {
        self.state = state
    }

    private func enemyAttack() {
        let enemyCells = state.cells.filter { $0.owner == .enemy && $0.health > 0 }
        let playerCells = state.cells.filter { $0.owner == .player && $0.health > 0 }

        guard !enemyCells.isEmpty, !playerCells.isEmpty else { return }

        if let attackingEnemy = enemyCells.randomElement(), let target = playerCells.randomElement() {
            let delay = Double.random(in: 5...10) // 🔥 Случайная задержка 5-10 сек

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if attackingEnemy.currentConnections < attackingEnemy.maxConnections {
                self.state.createConnection(from: attackingEnemy, to: target)
            }
            }
        }
    }
    
    func update() {
        guard !state.isGameOver else { return }

        // Удаляем клетки с 0 здоровьем
        removeDeadCells()
        enemyAttack()
        
        state.updateConnectionsCount()

        for i in 0..<state.connections.count {
            let connection = state.connections[i]

            guard
                let sourceIndex = state.cells.firstIndex(where: { $0.id == connection.sourceCellID }),
                let targetIndex = state.cells.firstIndex(where: { $0.id == connection.targetCellID })
            else {
                continue
            }

            let sourceCell = state.cells[sourceIndex]
            let targetCell = state.cells[targetIndex]

            if sourceCell.health > 0, targetCell.health > 0 {
                applyConnectionLogic(source: sourceCell, target: targetCell, connection: connection)
            }
        }

        checkWinLose()
        state.objectWillChange.send()
    }
    
    func applyConnectionLogic(source: CellModel, target: CellModel, connection: TentacleConnection) {
        if source.health <= 0 {
            print("⚠️ Мертвая клетка \(source.id) не может взаимодействовать.")
            return
        }
        // Сценарии зависят от владельцев
        switch (source.owner, target.owner) {
            // --- 1. Моя клетка -> моя клетка (лечение/передача) ---
        case (.player, .player):
            transferHealth(from: source.id, to: target.id)
            
            // --- 2. Моя клетка -> пустая (захват) ---
        case (.player, .neutral):
            captureNeutral(source: source.id, target: target.id, newOwner: .player)
            
            // --- 3. Моя клетка -> вражеская (атака) ---
        case (.player, .enemy):
            attack(source: source.id, target: target.id, newOwner: .player)
            
            // --- 4. Вражеская клетка -> пустая (захват) ---
        case (.enemy, .neutral):
            captureNeutral(source: source.id, target: target.id, newOwner: .enemy)
            
            // --- 5. Вражеская клетка -> моя клетка (атака) ---
        case (.enemy, .player):
            attack(source: source.id, target: target.id, newOwner: .enemy)
            
            // --- Остальные случаи (enemy->enemy, player->???) можно при желании тоже обрабатывать ---
        default:
            // Например, enemy->enemy = лечение для врага
            // Либо пропускаем, если не нужно
            break
        }
    }
    
    /// Передача здоровья между двумя клетками одного владельца
    private func transferHealth(from sourceID: UUID, to targetID: UUID) {
        guard
            let sIndex = state.cells.firstIndex(where: { $0.id == sourceID }),
            let tIndex = state.cells.firstIndex(where: { $0.id == targetID })
        else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Ждём завершения анимации
            let transferAmount = self.baseTransferSpeed
            if  self.state.cells[sIndex].health > transferAmount {
                self.state.cells[sIndex].health -= transferAmount
                self.state.cells[tIndex].health += transferAmount
            }
        }
    }
    
    /// Захват нейтральной клетки
    private func captureNeutral(source: UUID, target: UUID, newOwner: CellOwner) {
        guard
            let sIndex = state.cells.firstIndex(where: { $0.id == source }),
            let tIndex = state.cells.firstIndex(where: { $0.id == target })
        else { return }
        
        // Допустим, «атакуем» нейтральную клетку, снижая её здоровье
        let attackValue = baseAttackSpeed
        state.cells[tIndex].health -= attackValue
        if state.cells[tIndex].health <= 0 {
            // Становится владельцем
            state.cells[tIndex].owner = newOwner
            // Частично восстанавливаем здоровье
            state.cells[tIndex].health = 50
        }
    }
    
    /// Атака вражеской клетки
    private func attack(source: UUID, target: UUID, newOwner: CellOwner) {
        guard
            let sIndex = state.cells.firstIndex(where: { $0.id == source }),
            let tIndex = state.cells.firstIndex(where: { $0.id == target })
        else { return }
        
        let attackValue = baseAttackSpeed
        state.cells[tIndex].health -= attackValue
        state.cells[sIndex].health -= attackValue / 2 // Атакующая клетка тоже теряет здоровье

        if state.cells[tIndex].health <= 0 {
            state.cells[tIndex].owner = newOwner
            state.cells[tIndex].health = 10
        }

        if state.cells[sIndex].health <= 0 {
            print("⚠️ Атакующая клетка \(source) погибла в бою!")
        }
    }
    
    /// Проверяем условия победы/поражения
    private func checkWinLose() {
        let enemyCells = state.cells.filter { $0.owner == .enemy }
        let playerCells = state.cells.filter { $0.owner == .player }
        
        if enemyCells.isEmpty {
            // Победа
            state.isGameOver = true
            state.gameResult = .win
            state.stopTimer()
            state.starRating = 3
        } else if playerCells.isEmpty {
            // Поражение
            state.isGameOver = true
            state.gameResult = .lose
            state.stopTimer()
            state.starRating = nil
        }
    }
    
    private func removeDeadCells() {
        let deadCellIDs = state.cells.filter { $0.health <= 0 }.map { $0.id }
        if deadCellIDs.isEmpty { return }

        print("Removing dead cells: \(deadCellIDs)")

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 1)) {
            for id in deadCellIDs {
                if let index = self.state.cells.firstIndex(where: { $0.id == id }) {
                    self.state.cells[index].position.y += 20 // Уход вниз
                    self.state.cells[index].health = 0
                }
            }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state.cells.removeAll { deadCellIDs.contains($0.id) }
            self.state.connections.removeAll { connection in
                deadCellIDs.contains(connection.sourceCellID) || deadCellIDs.contains(connection.targetCellID)
            }
        }
    }
}

// MARK: - Игровое состояние (хранит данные, а логику делегирует GameLogic)
class GameState: ObservableObject {
    let currentLevel: Int
    
    @Published var cells: [CellModel] = []
    @Published var connections: [TentacleConnection] = []
    
    @Published var isGameOver = false
    @Published var gameResult: GameResultType = .none
    @Published var starRating: Int?
    
    private var timer: Timer?
    
    // Use lazy var to defer initialization until self is fully initialized
    lazy var logic: GameLogic = GameLogic(state: self)
    
    
    // Интервал обновления (каждые 0.2 секунды)
    let updateInterval: TimeInterval = 0.2
    
    init(level: Int) {
        self.currentLevel = level
        self.cells = levels[level]
        
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval,
                                     repeats: true) { [weak self] _ in
            self?.logic.update()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func updateConnectionsCount() {
        for i in cells.indices {
            let connectedCount = connections.filter {
                $0.sourceCellID == cells[i].id || $0.targetCellID == cells[i].id
            }.count
            cells[i].currentConnections = connectedCount
        }
    }
    
    /// Создание соединения (логично держать в GameState, но можно и в GameLogic)
    func createConnection(from source: CellModel, to target: CellModel) {
        print("Попытка создать соединение. Source: \(source.currentConnections)/\(source.maxConnections), Target: \(target.currentConnections)/\(target.maxConnections)")
        guard let sourceIndex = cells.firstIndex(where: { $0.id == source.id }),
              let targetIndex = cells.firstIndex(where: { $0.id == target.id }) else { return }

        // Убедимся, что у обеих клеток есть доступные слоты для соединений
        if cells[sourceIndex].currentConnections >= cells[sourceIndex].maxConnections ||
           cells[targetIndex].currentConnections >= cells[targetIndex].maxConnections {
            print("⚠️ Достигнут лимит соединений для одной из клеток!")
            return
        }

        // Проверяем, существует ли уже такое соединение (в обе стороны)
    if connections.contains(where: { ($0.sourceCellID == source.id && $0.targetCellID == target.id) ||
                                      ($0.sourceCellID == target.id && $0.targetCellID == source.id) }) {
        return
    }

        // Создаём соединение
        let newConnection = TentacleConnection(
            sourceCellID: source.id,
            targetCellID: target.id,
            owner: source.owner,
            progress: 0.0,
            strength: (source.type == .attack ? 2.0 : 1.0)
        )

        connections.append(newConnection)

        // Обновляем количество соединений
        cells[sourceIndex].currentConnections += 1
        cells[targetIndex].currentConnections += 1
    }
    
    func removeConnection(_ connection: TentacleConnection) {
        guard let sourceIndex = cells.firstIndex(where: { $0.id == connection.sourceCellID }),
              let targetIndex = cells.firstIndex(where: { $0.id == connection.targetCellID }) else { return }

        // Удаляем соединение
        connections.removeAll { $0.id == connection.id }

        // Освобождаем слоты соединений
        if let sourceIndex = cells.firstIndex(where: { $0.id == connection.sourceCellID }) {
            cells[sourceIndex].currentConnections = max(0, cells[sourceIndex].currentConnections - 1)
        }

        if let targetIndex = cells.firstIndex(where: { $0.id == connection.targetCellID }) {
            cells[targetIndex].currentConnections = max(0, cells[targetIndex].currentConnections - 1)
        }

        print("🔴 Соединение удалено: \(connection.id). Source connections: \(cells[sourceIndex].currentConnections), Target connections: \(cells[targetIndex].currentConnections)")
    }}

// MARK: - Экран игры
struct GameView: View {
    @ObservedObject var gameState: GameState
    
    @State private var dragStartCell: CellModel?
    @State private var dragLocation: CGPoint?
    
    var body: some View {
        ZStack {
            // Фон
            Assets.Images.backgroundImage
            
            // Линии (щупальца)
            ForEach(gameState.connections, id: \.id) { connection in
                if let source = gameState.cells.first(where: { $0.id == connection.sourceCellID }),
                   let target = gameState.cells.first(where: { $0.id == connection.targetCellID }) {
                    TentacleView(sourcePoint: source.position, targetPoint: target.position, owner: connection.owner,
                                 onConnectionComplete: {
                                     gameState.logic.applyConnectionLogic(source: source, target: target, connection: connection)
                                 },
                                 onDelete: {
                                     gameState.removeConnection(connection)
                                 })
                }
            }
            
//             Временная линия для визуализации соединения при drag
            if let startCell = dragStartCell, let loc = dragLocation {
                Path { path in
                    path.move(to: startCell.position)
                    path.addLine(to: loc)
                }
                .stroke(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [5, 5]))
                .animation(.easeInOut(duration: 0.2), value: dragLocation)
            }
            
            // Клетки
            ForEach(gameState.cells) { cell in
                CellView(cell: cell)
                    .position(cell.position)
                    .contentShape(Rectangle())
                    .scaleEffect(dragStartCell?.id == cell.id ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: dragStartCell)
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onChanged { value in
                                // ✅ Если палец двигается, а клетка ещё не выбрана, выбираем стартовую клетку
                                if dragStartCell == nil {
                                    if let newStartCell = gameState.cells.first(where: { distance($0.position, value.location) < 30 }) {
                                        dragStartCell = newStartCell
                                        print("Выбрана стартовая клетка: \(newStartCell.id)")
                                    }
                                }
                                dragLocation = value.location // Обновляем позицию пальца
                            }
                            .onEnded { _ in
                                if let startCell = dragStartCell, let endLocation = dragLocation, startCell.owner == .player {
                                    // Найти ближайшую клетку, но не саму себя
                                    let sortedCells = gameState.cells
                                        .filter { $0.id != startCell.id } // Исключаем начальную клетку
                                        .map { ($0, distance($0.position, endLocation)) } // Считаем расстояние
                                        .sorted { $0.1 < $1.1 } // Сортируем по минимальному расстоянию
                                    
                                    if let targetCell = sortedCells.first(where: { $0.1 < 50 })?.0 { // Увеличенный радиус
                                        print("Создаём соединение! \(startCell.id) → \(targetCell.id)")
                                        gameState.createConnection(from: startCell, to: targetCell)
                                    } else {
                                        print("Не удалось найти подходящую клетку")
                                    }
                                }
                                dragStartCell = nil
                                dragLocation = nil
                            }
                    )
            }
            
            // Экран результата
            if gameState.isGameOver {
                GameResultView(
                    result: gameState.gameResult,
                    stars: gameState.starRating,
                    onRestart: { result in
                        // Победил -> следующий уровень
                        // Проиграл -> тот же уровень
                        let nextLevel = (result == .win)
                        ? (gameState.currentLevel + 1)
                        : gameState.currentLevel
                        
                        let newState = GameState(level: nextLevel)
                        gameState.cells = newState.cells
                        gameState.connections = newState.connections
                        gameState.isGameOver = false
                        gameState.gameResult = .none
                        gameState.starRating = nil
                        gameState.startTimer()
                    },
                    onQuit: {
                        // Выход / меню
                    }
                )
            }
        }
        .onAppear {
            gameState.startTimer()
        }
        .onDisappear {
            gameState.stopTimer()
        }
    }
    
    func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }
}

// MARK: - Пример вью клетки
struct CellView: View {
    let cell: CellModel
    
    var body: some View {
        ZStack {
            // Примерно: подбираем картинку по владельцу/типу
            switch cell.owner {
            case .player:
                Assets.Cell.Player.red.resizable()
            case .enemy:
                Assets.Cell.Enemy.normal.resizable()
            case .neutral:
                Assets.Cell.empty.resizable()
            }
            
            // Обводка по владельцу
            Circle()
                .stroke(borderColor(for: cell.owner), lineWidth: 3)
                .frame(width: 60, height: 60)
                .overlay(Circle().stroke(Color.black.opacity(0.3), lineWidth: 1)) // Добавляем легкую тень
            
            // Текст: здоровье
            VStack {
                StrokedText(text: "\(Int(cell.health))", strokeColor: .black, textColor: .white,size: 24)
                StrokedText(text: "\(Int(cell.maxConnections - cell.currentConnections))", strokeColor: .black, textColor: .white, size: 24)
            }
        }
        .frame(width: 80, height: 80)
        .allowsHitTesting(true)
    }
    
    func borderColor(for owner: CellOwner) -> Color {
        switch owner {
        case .player:
            return .blue
        case .enemy:
            return .red
        case .neutral:
            return .gray
        }
    }
}

// MARK: - Пример вью для линии (щупальца)
struct TentacleView: View {
    let sourcePoint: CGPoint
    let targetPoint: CGPoint
    let owner: CellOwner
    let onConnectionComplete: () -> Void
    let onDelete: () -> Void

    @State private var progress: CGFloat = 0.0
    @State private var isDeleting: Bool = false

    var body: some View {
        ZStack {
            // Основная линия соединения
            Path { path in
                path.move(to: sourcePoint)
                path.addLine(to: targetPoint)
            }
            .trim(from: 0, to: progress)
            .stroke(owner == .player ? .blue : .red, lineWidth: 8)
            .animation(.linear(duration: isDeleting ? 0.5 : 2), value: progress)
        }
        // Гарантируем, что можно нажать
        .onAppear {
            withAnimation(.linear(duration: 2)) {
                progress = 1.0
            }
        }
        .containerShape(Capsule())
        .onTapGesture {
            print("✅ TAP detected on connection!")
            isDeleting = true
            withAnimation(.linear(duration: 0.5)) {
                progress = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onDelete()
            }
        }
    }

    private func midpoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }
}

// MARK: - Превью
struct Game_Preview: PreviewProvider {
    static var previews: some View {
        let state = GameState(level: 1)
        GameView(gameState: state)
    }
}
