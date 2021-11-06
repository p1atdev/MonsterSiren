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
                        
                        TabBarView(playerViewModel: playerViewModel)
                            .frame(maxWidth: min(window.width / 4.5, 400))
                            .padding(.top, 32)
                        
                        // 画面細長い時は再生操作画面のみ
                    }
//                    } else if geometry.size.width < 420  {
//
//                        TabBarView(playerViewModel: playerViewModel)
//                            .padding(.horizontal, 32)
//                    }
                    
//                    if geometry.size.width > 420  {
                        switch currentView {
                        default:
                            AlbumsView(loaded: $loaded)
                                .frame(maxWidth: .infinity)
                        }
//                    }
                }
                
                LoadingBannerView(loaded: $loaded)
            }
        }
        .ignoresSafeArea()
    }
}

//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        RootView()
//    }
//}
