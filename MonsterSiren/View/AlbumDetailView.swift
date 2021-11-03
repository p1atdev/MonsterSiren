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
    
    /// ホバー状態の曲
    @State private var overSong: Song?
    
    /// プレイヤー
    @ObservedObject var playerViewModel: PlayerViewModel
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                // ジャケット画像とアルバム名
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
//                    .frame(height: window.height / 3, alignment: .top)
                    .clipped()
                    
                    // アルバムのジャケ画像とアルバム名
                    if let album = album {
                        HStack(alignment: .bottom) {
                            
                            URLImageView(viewModel: .init(url: album.coverUrl))
                                .aspectRatio(1, contentMode: .fit)
                                .frame(height: 275)
                                .offset(y: 80)
                                .fixedSize()
                            
                            Text(album.name)
                                .font(.system(size: 54))
                                .fontWeight(.heavy)
                                .padding()
                            
                            Spacer()
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, 32)
                    }
                    
                    // 戻るボタン
                    HStack {
                        // 戻るボタン
                        Button(action: {
                            withAnimation {
                                album = nil
                            }
                        }, label: {
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: 128, height: 48)
                                    .foregroundColor(.init(white: 0.2))
                                    .shadow(color: .black,
                                            radius: 12,
                                            x: -4, y: 8)
                                Image(systemName: "chevron.left")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                            }
                        })
                            .padding()
                        Spacer()
                    }
                    
                }
                
                
                // 右側にアルバム全再生ボタン
                HStack {
                    Spacer()
                    
                    Button(action: {
                        
                        // TODO: 再生する
                        
                    }, label: {
                        
                        ZStack {
                            
                            Circle()
                                .foregroundColor(Color("blue"))
                            
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                            
                        }
                        .frame(width: 64, height: 64, alignment: .center)
                        
                    })
                        .offset(x: -72)
                }
                
                // 曲一覧を表示
                VStack(alignment: .leading, spacing: 8) {
                    if let songs = songs {
                        ForEach(0..<songs.count) { index in
                            let song = songs[index]
                            Button(action: {
                                // 曲を再生する
                                playerViewModel.play(song: song, albumDetail: albumDetail)
                                
                            }, label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(
                                            overSong?.id == song.id
                                            ? Color(.gray).opacity(0.4)
                                            : Color(.black)
                                        )
                                    
                                    HStack {
                                        
                                        // ホバー中は再生ボタンを出す
                                        if overSong?.id == song.id {
                                            Image(systemName: "play.fill")
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                                .font(.title)
                                                .padding()
                                        } else {
                                            Text(String(index+1))
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                                .font(.title.bold())
                                                .padding()
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(song.name)
                                                .font(.system(size: 24))
                                            Text(song.artistes.joined(separator: ", "))
                                                .font(.system(size: 18))
                                                .opacity(0.8)
                                        }
                                        
                                        Spacer()
                                        
                                        Image("rhodes")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                            .opacity(0.4)
                                    }
                                    .padding()
                                }
                                .onHover { over in
                                    if over {
                                        overSong = song
                                    } else {
                                        overSong = nil
                                    }
                                }
                            })
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 64)
                .onAppear {
                    withAnimation {
                        loaded = false
                    }
                    album?.getDetail(completion: { detail in
                        withAnimation {
                            self.albumDetail = detail
                            self.songs = detail?.songs
                            loaded = true
                        }
                    })
                }
                
            }
            
        }.background(Color.black)
    }
}
