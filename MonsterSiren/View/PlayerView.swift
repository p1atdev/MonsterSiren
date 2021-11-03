//
//  Player.swift
//  Player
//
//  Created by 周廷叡 on 2021/11/02.
//

import SwiftUI

struct PlayerView: View {
    
    @ObservedObject var playerViewModel: PlayerViewModel
    
    // 曲名のスクロール
    @State var scrollText: Bool = false
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                
                Spacer()
                
                if let album = playerViewModel.currentAlbum {
                    URLImageView(viewModel: .init(url: album.coverUrl))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(minWidth: proxy.size.width - 16,
                               minHeight: proxy.size.width - 16)
                        .shadow(color: .black, radius: 12,
                                x: -4, y: 8)
                        .padding(.horizontal)
                    //                        .padding(.bottom)
                } else {
                    Image("disk")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(minWidth: proxy.size.width - 16,
                               minHeight: proxy.size.width - 16)
                        .shadow(color: .black, radius: 12,
                                x: -4, y: 8)
                        .padding(.horizontal)
                    //                        .padding(.bottom)
                }
                
                
                HStack {
                    VStack(alignment: .leading) {
                        
                        Text(playerViewModel.currentSong?.name ?? "Song")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        
                        // アーティスト
                        Text(playerViewModel.currentSong?.artists.joined(separator: ", ") ?? "Artists")
                            .font(.system(size: 20))
                            .opacity(0.7)
                            .foregroundColor(.white)
                    }
                    .frame(height: 64)
                    
                    Spacer()
                    // TODO: お気に入りボタン?
                    
                    Image("rhodes")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                //            Spacer()
                
                // スライダー
//                Slider()
                    
                
                // ボタン系
                //            HStack {
                //
                //                // 前の曲
                //
                //                // 再生、停止
                //
                //                // 次の曲
                //
                //            }
            }
        }
    }
}

