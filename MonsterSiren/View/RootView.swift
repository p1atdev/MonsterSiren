//
//  RootView.swift
//  RootView
//
//  Created by 周廷叡 on 2021/11/02.
//

import SwiftUI

struct RootView: View {
    /// ロードの完了状態
    @State var loaded: Bool = false
    
    /// 右側に表示するビューの種類
    @State var currentView: String = "albums"
    
    /// 再生に関するモデル
    @ObservedObject var playerViewModel = PlayerViewModel()
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            // 背景画像
            Image("background")
                .resizable()
            
            HStack(spacing: 0) {
                TabBarView(playerViewModel: playerViewModel)
                    .frame(maxWidth: min(window.width / 5, 400))
                    .padding(.top, 32)
                
//                NavigationView {
                    switch currentView {
                    default:
                        AlbumsView(loaded: $loaded, playerViewModel: playerViewModel)
                            .frame(maxWidth: .infinity)
                    }
//                }
//                .frame(maxWidth: .infinity)
            }
            
            LoadingBannerView(loaded: $loaded)
        }
        .ignoresSafeArea()
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}