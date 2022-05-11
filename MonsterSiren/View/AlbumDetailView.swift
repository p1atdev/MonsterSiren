//
//  AlbumDetailView.swift
//  AlbumDetailView
//
//  Created by p1atdev on 2021/11/02.
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
    
    /// viewmodel
    @StateObject var albumDetailViewModel = AlbumDetailViewModel()
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 戻るボタン
            BackButton(onAction: {
                withAnimation {
                    album = nil
                    loaded = true
                }
            })
                .zIndex(50)
            
            GeometryReader { geometry in
                
                ScrollView {
                    
                    VStack {
                        
                        if geometry.size.width > 750 {
                            //MARK: 画面広いデバイス
                            
                            // MARK: ジャケット画像とアルバム名
                            ZStack(alignment: .top) {
                                
                                GeometryReader { reader -> AnyView in
                                    
                                    let offset = reader.frame(in: .global).minY
                                    
                                    return AnyView(
                                        ZStack(alignment: .center) {
                                            // 後ろのグラデーション
                                            LinearGradient(gradient: Gradient(colors: [.black, .gray.opacity(0)]),
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                            
                                            if let albumDetail = albumDetail {
                                                // でかいバナー画像
                                                URLImageView(viewModel: .init(url: albumDetail.coverDeUrl))
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: reader.size.width)
                                                    .overlay(
                                                        Rectangle()
                                                            .foregroundColor(.black)
                                                            .opacity(0.4)
                                                            .blur(radius: 8)
                                                    )
                                            }
                                        }
                                            .frame(minHeight: window.height / 4
                                                   + (offset > 0 ? offset : 0))
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
                                            .offset(y: offset > 0 ? -offset : 0)
                                    )
                                    
                                }
                                
                                
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
                                    
                                    .padding(.horizontal, 32)
                                    .padding(.bottom, 50)
                                }
                            }
                            .padding(.top, 32)
                            
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    Task {
                                        // アルバムの一番上から再生
                                        guard let songs = songs else { return }
                                        await playerViewModel.play(song: songs[0], albumDetail: albumDetail)
                                    }
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
                                .offset(x: -72)
                            }
                            
                        } else {
                            // MARK: iPhoneとかの画面細いデバイスの時
                            ZStack(alignment: .top) {
                                
                                GeometryReader { reader -> AnyView in
                                    
                                    let offset = reader.frame(in: .global).minY
                                    
                                    return AnyView(
                                        ZStack(alignment: .center) {
                                            // 後ろのグラデーション
                                            LinearGradient(gradient: Gradient(colors: [.black, .gray.opacity(0)]),
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                            
                                            if let albumDetail = albumDetail {
                                                // でかいバナー画像
                                                URLImageView(viewModel: .init(url: albumDetail.coverDeUrl))
                                                    .scaledToFill()
                                                    .frame(width: reader.size.width)
                                                    .overlay(
                                                        Rectangle()
                                                            .foregroundColor(.black)
                                                            .opacity(0.4)
                                                            .blur(radius: 8)
                                                    )
                                            }
                                        }
                                            .frame(minHeight: window.height / 4
                                                   + (offset > 0 ? offset : 0))
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
                                            .offset(y: (offset > 0 ? -offset : 0))
                                    )
                                }
//                                .frame(maxHeight: window.height / 2)
                                
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
//                                            .padding(.top, safeAreaIntents.top + 64)
                                            .overlay(
                                                ZStack {
                                                    Button(action: {
                                                        Task {
                                                            // アルバムの一番上から再生
                                                            guard let songs = songs else { return }
                                                            await playerViewModel.play(song: songs[0], albumDetail: albumDetail)
                                                        }
                                                    }, label: {
                                                        
                                                        ZStack {
                                                            Circle()
                                                                .foregroundColor(Color("blue"))
                                                            
                                                            Image(systemName: "play.fill")
                                                                .foregroundColor(.white)
                                                                .font(.title2)
                                                        }
                                                        
                                                    })
                                                    .frame(width: 64,
                                                           height: 64,
                                                           alignment: .bottomTrailing)
                                                    .offset(x: 20,
                                                            y: 16)
                                                } // ZStack
                                                    .frame(maxWidth: .infinity,
                                                           maxHeight: .infinity,
                                                           alignment: .bottomTrailing)
                                            )
                                        
                                        
                                        Text(album.name)
                                            .font(window.width > 1000
                                                  ? .system(size: 32)
                                                  : .largeTitle)
                                            .fontWeight(.heavy)
                                            .frame(maxWidth: .infinity,
                                                   alignment: .leading)
                                            .padding()
                                            .foregroundColor(.white)
                                        
                                    }
                                    .padding()
                                    .padding(.top, 120)
                                }
                            }
                        }

                        // 曲一覧
                        SongsList(album: $album,
                                  songs: $songs,
                                  albumDetail: $albumDetail,
                                  loaded: $loaded)
                            .padding(.horizontal, geometry.size.width > 750 ? 64 : 8)
                            .padding(.bottom, 128)
                        
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
}

struct AlbumDetail_Preview: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            AlbumDetailView(album: Binding.constant(Album(id: "4520",
                                                          name: "愚人号OST",
                                                          coverUrl: "https://web.hycdn.cn/siren/pic/20220509/60c48c2cd057afb6d4dcd65cae5c3fe9.jpg",
                                                          artistes: ["塞壬唱片-MSR"])),
                            loaded: Binding.constant(true))
            .ignoresSafeArea()
            .environmentObject(PlayerViewModel())
//            .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
