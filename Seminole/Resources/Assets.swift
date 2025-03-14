//
//  Assets.swift
//  Seminole
//
//  Created by Pavel Ivanov on 13.03.2025.
//

import SwiftUI

struct Assets {
    enum Images {
        static let backgroundImage: some View = {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        }()
        static let logo: some View = {
            Image("logo")
                .resizable()
                .frame(width: 340, height: 340)
                .edgesIgnoringSafeArea(.all)
        }()
        
    }
    
    enum Button {
        static let settings = Image("settingsButton")
        static let shop = Image("shopButton")
        static let home = Image("homeButton")
        static let main = Image("defaultButton")
        static let soundOn = Image("sound_on")
        static let soundOff = Image("sound_off")
    }
}

extension Font {
    static func Cubano(size: CGFloat = 44) -> Font {
        return .custom("Cubano", size: size)
    }
}
