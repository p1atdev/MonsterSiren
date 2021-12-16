//
//  AlbumDetailView.swift
//  AlbumDetailView
//
//  Created by 周廷叡 on 2021/11/02.
//

import SwiftUI

struct AlbumDetailView: View {
    
    /// もらったアルバム
    @Binding var album: Album?
    
    /// アルバム詳細
    @State var albumDetail: AlbumDetail?
    
    /// アルバムの曲一覧
    @State var songs: [Song]?
    
    /// ロードが完了したか
    @Binding var loaded: Bool
    
    /// プレイヤー
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        GeometryReader { geometry in
            
            ScrollView {
                
                VStack {
                    
                    if geometry.size.width > 750 {
                        //MARK: 画面広いデバイス
                        
                        // MARK: ジャケット画像とアルバム名
                        ZStack(alignment: .top) {
                            
                            GeometryReader { reader in
                                // 後ろのグラデーション
                                LinearGradient(gradient: Gradient(colors: [.black, .gray.opacity(0)]),
                                               startPoint: .top,
                                               endPoint: .bottom)
                                
                                if let albumDetail = albumDetail {
                                    // でかいバナー画像
                                    URLImageView(viewModel: .init(url: albumDetail.coverDeUrl))
                                        .scaledToFill()
                                        .overlay(
                                            Rectangle()
                                                .foregroundColor(.black)
                                                .opacity(0.4)
                                                .blur(radius: 8)
                                        )
                                }
                            }
                            .frame(minHeight: window.height / 4)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [Color](repeating: Color.black,
                                                        count: 7)
                                        + [Color.black.opacity(0)]
                                    ),
                                    startPoint: .top,
                                    endPoint: .bottom)
                            )
                            
                            // アルバムのジャケ画像とアルバム名
                            if let album = album {
                                
                                HStack(alignment: .bottom) {
                                    
                                    URLImageView(viewModel: .init(url: album.coverUrl))
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(height: min(275, window.height / 4))
                                        .offset(y: 80)
                                        .shadow(color: .black,
                                                radius: 12,
                                                x: -4,
                                                y: 8)
                                    
                                    
                                    Text(album.name)
                                        .font(window.width > 1000
                                              ? .system(size: 54)
                                              : .largeTitle)
                                        .fontWeight(.heavy)
                                        .padding()
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(.top, 32)
                                .padding(.horizontal, 32)
                                .padding(.bottom, 50)
                            }
                            
                            
                            // 戻るボタン
                            BackButton(onAction: {
                                withAnimation {
                                    album = nil
                                    loaded = true
                                }
                            })
                        }
                    } else {
                        // MARK: iPhoneとかの画面細いデバイスの時
                        ZStack(alignment: .top) {
                            
                            GeometryReader { reader in
                                // 後ろのグラデーション
                                LinearGradient(gradient: Gradient(colors: [.black, .gray.opacity(0)]),
                                               startPoint: .top,
                                               endPoint: .bottom)
                                
                                if let albumDetail = albumDetail {
                                    // でかいバナー画像
                                    URLImageView(viewModel: .init(url: albumDetail.coverDeUrl))
                                        .scaledToFill()
                                        .overlay(
                                            Rectangle()
                                                .foregroundColor(.black)
                                                .opacity(0.4)
                                                .blur(radius: 8)
                                        )
                                        .mask(
                                            LinearGradient(
                                                gradient: Gradient(
                                                    colors: [Color](repeating: Color.black,
                                                                    count: 3)
                                                    + [Color.black.opacity(0)]
                                                ),
                                                startPoint: .top,
                                                endPoint: .bottom)
                                        )
                                }
                            }
                            .frame(maxHeight: window.height / 2)
                            
                            // アルバムのジャケ画像とアルバム名
                            if let album = album {
                                VStack(alignment: .center) {
                                    
                                    URLImageView(viewModel: .init(url: album.coverUrl))
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(minWidth:  160, maxWidth: 240)
                                        .shadow(color: .black.opacity(0.5),
                                                radius: 12,
                                                x: -4,
                                                y: 8)
                                        .padding(.top, safeAreaIntents.top + 64)
                                    
                                    
                                    Text(album.name)
                                        .font(window.width > 1000
                                              ? .system(size: 32)
                                              : .largeTitle)
                                        .fontWeight(.heavy)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .foregroundColor(.white)
                                    
                                }
                                .padding()
                            }
                            
                            // 戻るボタン
                            BackButton(onAction: {
                                withAnimation {
                                    album = nil
                                    loaded = true
                                }
                            })
                        }
                    }
                    
                    // 右側にアルバム全再生ボタン
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            
                            // アルバムの一番上から再生
                            guard let songs = songs else { return }
                            playerViewModel.play(song: songs[0], albumDetail: albumDetail)
                            
                        }, label: {
                            
                            ZStack {
                                
                                Circle()
                                    .foregroundColor(Color("blue"))
                                
                                Image(systemName: "play.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                
                            }
                            .frame(width: 64, height: 64, alignment: .center)
                            // 画面めっちゃ細い時はアルバム画像の右下になるように移動させる
                            .offset(y: geometry.size.width > 750
                                    ? -28
                                    : geometry.size.width > 450
                                    ? -72
                                    : -140)
                            
                        })
                            .offset(x: geometry.size.width > 750 ? -72 : -36)
                    }
                    
                    // 曲一覧
                    SongsList(album: $album,
                              songs: $songs,
                              albumDetail: $albumDetail,
                              loaded: $loaded)
                        .padding(.horizontal, geometry.size.width > 750 ? 64 : 16)
                    
                }
                
            }
            
            .background(
                Image("background")
                    .resizable()
                    .clipped()
            )
        }
    }
}
