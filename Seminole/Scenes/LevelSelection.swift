//
//  LevelSelection.swift
//  Seminole
//
//  Created by Pavel Ivanov on 15.03.2025.
//

import SwiftUI

struct LevelSelectionView: View {
    
    // MARK: - Модель данных
    private let levels: [LevelModel] = LevelStorage.shared.loadLevels()
    
    // Колонки для сетки
    private let columns = Array(repeating: GridItem(.fixed(90), spacing: 8), count: 4)
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    @Binding var path: NavigationPath  // Используем path для навигации
    
    var body: some View {
        ZStack(alignment: .top) {
            Assets.Images.backgroundImage
                .ignoresSafeArea()

            VStack {
                // Верхняя панель навигации
                NavigationItem(title: "LEVELS", type: .back, action: {
                    presentationMode.wrappedValue.dismiss()
                })
                .padding(.bottom)
                
                VStack {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(levels) { level in
                            LevelCellView(level: level) {
                                path.append(String(level.number))
                            }
                            .disabled(level.isLocked)
                            .frame(width: 90, height: 90)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Уровень (пример модели)
struct LevelModel: Identifiable, Codable {
    let id: UUID
    let number: Int
    let isLocked: Bool
    let stars: Int?

    init(
        id: UUID = UUID(),
        number: Int,
        isLocked: Bool,
        stars: Int?
    ) {
        self.id = id
        self.number = number
        self.isLocked = isLocked
        self.stars = stars
    }
}

// MARK: - Ячейка уровня
struct LevelCellView: View {
    let level: LevelModel
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            guard !level.isLocked else { return }
            action()
        }) {
            ZStack {
                (level.isLocked ? Assets.Cell.locked : Assets.Cell.Enemy.normal)
                    .resizable()
                    .frame(width: 90, height: 90) // Теперь всегда квадратные

                if !level.isLocked {
                    VStack {
                        StrokedText(
                            text: "\(level.number)",
                            strokeColor: .black,
                            textColor: .white,
                            size: 32
                        )

                        if let stars = level.stars {
                            HStack(spacing: 2) {
                                ForEach(1...3, id: \.self) { index in
                                    (index <= stars ? Assets.Star.filled : Assets.Star.empty)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                            }
                            .padding(.top, -16) // Поднимаем звезды выше
                        }
                    }
                }
            }
        }
    }
}
