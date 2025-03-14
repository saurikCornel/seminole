//
//  SettingsView.swift
//  Seminole
//
//  Created by Pavel Ivanov on 13.03.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var soundEnabled = true
    
    var body: some View {
        ZStack {
            Assets.Images.backgroundImage
            
            VStack(spacing: 16) {
                ZStack(alignment: .center) {
                    StrokedText(text: "SETTINGS", strokeColor: .black, textColor: .white)
                    
                    HStack {
                        Button(action: {
                            // Действие для закрытия экрана
                            dismiss()
                        }) {
                            Assets.Button.home
                                .resizable()
                                .frame(width: Constants.Button.circleSmall.width, height: Constants.Button.circleSmall.height)
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
                
                
                Spacer()
                
                Button(action: {
                    soundEnabled.toggle()
                }) {
                    soundEnabled ? Assets.Button.soundOn.resizable() : Assets.Button.soundOff.resizable()
                }
                .frame(width: 150, height: 150)
                
                StrokedText(
                    text: soundEnabled ? "SOUND: ON" : "SOUND: OFF",
                    strokeColor: .white,
                    textColor: soundEnabled ? .black : .gray,
                    strokeWidth: 1,
                    size: 32
                )
                
                Spacer()
                
                NavigationLink(destination: RulesView()) {
                    MainButton(text: "RULES")
                }
            }.padding()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct RulesView: View {
    var body: some View {
        ZStack {
            Assets.Images.backgroundImage
            Text("Game Rules Placeholder")
                .font(.title)
                .foregroundColor(.white)
                .shadow(radius: 5)
        }
    }
}

#Preview {
    SettingsView()
}
