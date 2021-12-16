//
//  ContentsView.swift
//  ContentsView
//
//  Created by p1atdev on 2021/11/02.
//

import SwiftUI

struct ContentsView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        RootView()
            .frame(minWidth: 360 , minHeight: 570)
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .background:
                    print("バックグラウンド！")
                case .inactive:
                    print("バックグラウンドorフォアグラウンド直前")
                case .active:
                    print("フォアグラウンド！")
                @unknown default:
                    fatalError("想定していないステータス")
                }
            }
    }
}
