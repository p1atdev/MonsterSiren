//
//  RootView.swift
//  RootView
//
//  Created by p1atdev on 2021/11/02.
//

import SwiftUI

struct RootView: View {
    /// ロードの完了状態
    @State var loaded: Bool = false
    
    /// 右側に表示するビューの種類
    @State var currentView: String = "albums"
    
    /// 再生に関するモデル
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景画像
                Image("background")
                    .resizable()
                
                HStack(spacing: 0) {
                    
                    if geometry.size.width > 750 {
                        
                        TabBarView()
                            .frame(maxWidth: min(window.width / 4.5, 400))
                            .padding(.top, 32)
                    }
                    
                    switch currentView {
                        
                    default:
                        AlbumsView(loaded: $loaded)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                if geometry.size.width <= 750 {
                    // ミニプレーヤーを出して、もしタップされたらPlayerViewを出す
                    MiniPlayer()
                }
                
                LoadingBannerView(loaded: $loaded)
            }
        }
        .ignoresSafeArea()
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            RootView()
                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
                .environmentObject(PlayerViewModel())
                .previewInterfaceOrientation(.landscapeRight)
        } else {
            // Fallback on earlier versions
        }
    }
}
