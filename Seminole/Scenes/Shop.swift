//
//  Shop.swift
//  Seminole
//
//  Created by Pavel Ivanov on 17.03.2025.
//

import SwiftUI

struct ShopView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSkin: String = "skin1" // Выбранный скин
    @State private var stars: Int = 37 // Количество звезд игрока
    
    @State private var ownedSkins: Set<String> = ["1"] // Набор купленных скинов
    
    private let items: [ShopItem] = [
        ShopItem(id: "sphere1", image: Assets.Sphere.first, price: 0),
        ShopItem(id: "sphere2", image: Assets.Sphere.second, price: 25),
        ShopItem(id: "sphere3", image: Assets.Sphere.third, price: 50),
        ShopItem(id: "sphere4", image: Assets.Sphere.fourth, price: 75),
        ShopItem(id: "skin1", image: Assets.Cell.Player.red, price: 0),
        ShopItem(id: "skin2", image: Assets.Cell.Player.purple, price: 10),
        ShopItem(id: "skin3", image: Assets.Cell.Player.green, price: 20)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Assets.Images.backgroundImage
            
            VStack {
                GridView(items: items, selectedSkin: $selectedSkin, stars: $stars, ownedSkins: $ownedSkins)
            }
            
            VStack {
                NavigationItem(title: "SHOP", type: .home, action: {
                    presentationMode.wrappedValue.dismiss()
                })
                
                HStack {
                    StrokedText(text: "\(stars)", strokeColor: .black, textColor: .yellow, size: 32)
                    Assets.Star.filled
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }.padding()
        }.navigationBarBackButtonHidden()
    }
}

// MARK: - Модель предмета магазина
struct ShopItem: Identifiable {
    let id: String
    let image: Image
    let price: Int
}

// MARK: - Отображение предметов в магазине
struct GridView: View {
    let items: [ShopItem]
    @Binding var selectedSkin: String
    @Binding var stars: Int
    @Binding var ownedSkins: Set<String>
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(items) { item in
                VStack {
                    item.image
                        .resizable()
                        .frame(width: 90, height: 90)
                    
                    if ownedSkins.contains(item.id) {
                        if selectedSkin == item.id {
                            Text("SELECTED")
                                .foregroundColor(.yellow)
                                .bold()
                        } else {
                            Button(action: {
                                selectedSkin = item.id
                            }) {
                                
                                ShopButton(text: "SELECT")
                            }
                        }
                    } else {
                        Button(action: {
                            buyItem(item)
                        }) {
                            ShopButton(text: "Buy for \(item.price) stars")
                        }
                        .disabled(stars < item.price)
                    }
                }
            }
        }.onAppear(perform: {
            <#code#>
        })
        .onDisappear(perform: {
            <#code#>
        })
        .padding()
    }
    
    private func buyItem(_ item: ShopItem) {
        guard stars >= item.price else { return }
        stars -= item.price
        ownedSkins.insert(item.id)
        selectedSkin = item.id
    }
}

struct Sphere: View {
    let text: String
    var state: State = .buy
    let onTap: () -> Void
    
    var body: some View {
        
        VStack {
            
        }
        
        ZStack {
            Assets.Button.main
                .resizable()
                .frame(width: 100, height: 40)
            StrokedText(text: text, strokeColor: .black, textColor: .white, size: 16)
        }
        
        MainButton(text: "By", strokeColor: <#T##Color#>, textColor: <#T##Color#>, size: <#T##CGFloat#>, action: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
    
    enum State {
        case buy
        case select
        case selected
    }
}

// MARK: - Превью
#Preview {
    ShopView()
}
