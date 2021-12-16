//
//  BackButton.swift
//  MonsterSiren
//
//  Created by p1atdev on 2021/12/16.
//

import SwiftUI

struct BackButton: View {
    
    var onAction: () -> Void
    
    var body: some View {
        // 戻るボタン
        HStack {
            // 戻るボタン
            Button(action: {
                onAction()
            }, label: {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: 128, height: 48)
                        .foregroundColor(.init(white: 0.2))
                        .shadow(color: .black.opacity(0.8),
                                radius: 12,
                                x: -4, y: 8)
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.leading)
                }
            })
                .padding(.horizontal)
                .padding(.top, safeAreaIntents.top)
            
            Spacer()
        }
    }
}
