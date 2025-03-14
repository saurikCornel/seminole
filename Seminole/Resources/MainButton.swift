//
//  MainButton.swift
//  Seminole
//
//  Created by Pavel Ivanov on 13.03.2025.
//

import SwiftUI

struct MainButton: View {
    
    let text: String
    let strokeColor: Color
    let textColor: Color
    let size: CGFloat
    
    init(text: String, strokeColor: Color = .black, textColor: Color = .white, size: CGFloat = 36) {
        self.text = text
        self.strokeColor = strokeColor
        self.textColor = textColor
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Assets.Button.main
                .resizable()
                .frame(width: Constants.Button.rectangleBig.width, height: Constants.Button.rectangleBig.height)
            StrokedText(
                text: text,
                strokeColor: strokeColor,
                textColor: textColor,
                size: size
            )
        }
    }
}
