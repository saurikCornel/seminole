//
//  ContentView.swift
//  Seminole
//
//  Created by Pavel Ivanov on 13.03.2025.
//

import SwiftUI

@main
struct SeminoleGamesApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Assets.Images.backgroundImage
                Assets.Images.logo
                
                VStack(spacing: 20) {
                    HStack {
                        NavigationLink(destination: SettingsView()) {
                            Assets.Button.settings
                                .resizable()
                                .frame(width: Constants.Button.circleBig.width, height: Constants.Button.circleBig.width)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        NavigationLink(destination: ShopView()) {
                            Assets.Button.shop
                                .resizable()
                                .frame(width: Constants.Button.circleBig.width, height: Constants.Button.circleBig.width)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: GameView()) {
                        MainButton(text: "START", size: 44)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }
}

struct GameView: View {
    var body: some View {
        ZStack {
            Assets.Images.backgroundImage
            
            Text("Game Screen - Placeholder")
                .font(.title)
                .foregroundColor(.white)
                .shadow(radius: 5)
        }
    }
}

struct ShopView: View {
    var body: some View {
        ZStack {
            Assets.Images.backgroundImage
            
            Text("Shop Screen - Placeholder")
                .font(.title)
                .foregroundColor(.white)
                .shadow(radius: 5)
        }
    }
}

#Preview {
    MainMenuView()
}

enum Constants {
    enum Button {
        static let circleBig = CGSize(width: 80, height: 80)
        static let circleSmall = CGSize(width: 60, height: 60)
        static let rectangleBig = CGSize(width: 240, height: 80)
    }
}
