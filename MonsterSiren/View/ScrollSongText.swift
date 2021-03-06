//
//  ScrollSongText.swift
//  MonsterSiren
//
//  Created by p1atdev on 2022/02/03.
//

import Foundation
import UIKit
import SwiftUI

struct ScrollSongText: View {
    
    @Binding var songName: String
    @State var fontSize: CGFloat
    @State var wrapWidth: CGFloat
    
    @State private var offset: CGFloat = 0
    @State private var shouldScrollText: Bool = false
    @State private var textWidth: CGFloat = 0
    
    var scrollAnimation: Animation {
        Animation
            .easeInOut(duration: 5) //.easeIn, .easyOut, .linear, etc...
            .delay(2)
            .repeatForever()
    }
    
    func setScroll(_ text: String) {
        textWidth = text.widthOfString(usingFont: UIFont.systemFont(ofSize: fontSize, weight: .regular))
        
        shouldScrollText = textWidth > wrapWidth
        
        if shouldScrollText {
            withAnimation(Animation.linear(duration: 8).delay(2).repeatForever(autoreverses: true)) {
                offset = -textWidth / 3
            }
        } else {
            offset = 0
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GeometryReader { textProxy in
                Text(songName)
                    .font(.system(size: fontSize))
                    .frame(width: textWidth)
                    .offset(x: shouldScrollText ? offset : 0, y: 0)
                    .onAppear {
                        setScroll(songName)
                    }
                    .onChange(of: songName) { [songName] newSongName in
                        setScroll(newSongName)
                    }
                    .fixedSize()
            }
        }
        
    }
}
