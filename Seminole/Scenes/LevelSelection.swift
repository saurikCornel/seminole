//
//  LevelSelection.swift
//  Seminole
//
//  Created by Pavel Ivanov on 15.03.2025.
//

import SwiftUI

struct LevelSelectionView: View {
    
    // MARK: - Модель данных (в демо — статичная)
    private let levels: [LevelModel] = [
        LevelModel(number: 1, isLocked: false, stars: 2),
        LevelModel(number: 2, isLocked: false, stars: 3),
        LevelModel(number: 3, isLocked: false, stars: 1),
        LevelModel(number: 4, isLocked: false, stars: 0),
        // Дополняем до 20 уровней
        LevelModel(number: 5, isLocked: false, stars: 3),
        LevelModel(number: 6, isLocked: true, stars: nil),
        LevelModel(number: 7, isLocked: true, stars: nil),
        LevelModel(number: 8, isLocked: true, stars: nil),
        LevelModel(number: 9, isLocked: true, stars: nil),
        LevelModel(number: 10, isLocked: true, stars: nil),
        LevelModel(number: 11, isLocked: true, stars: nil),
        LevelModel(number: 12, isLocked: true, stars: nil),
        LevelModel(number: 13, isLocked: true, stars: nil),
        LevelModel(number: 14, isLocked: true, stars: nil),
        LevelModel(number: 15, isLocked: true, stars: nil),
        LevelModel(number: 16, isLocked: true, stars: nil),
        LevelModel(number: 17, isLocked: true, stars: nil),
        LevelModel(number: 18, isLocked: true, stars: nil),
        LevelModel(number: 19, isLocked: true, stars: nil),
        LevelModel(number: 20, isLocked: true, stars: nil)
    ]
    
    // Колонки для сетки
    private let columns = Array(repeating: GridItem(.fixed(90), spacing: 8), count: 4)
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    
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
                                // Обработка нажатия
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
struct LevelModel: Identifiable {
    let id = UUID()
    let number: Int
    let isLocked: Bool
    let stars: Int?
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

#Preview {
    LevelSelectionView()
}
