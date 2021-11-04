//
//  Player.swift
//  Player
//
//  Created by 周廷叡 on 2021/11/02.
//

import SwiftUI

struct PlayerView: View {
    
    /// シャッフルするか
    @AppStorage("isShuffled") private var isShuffled: Bool = false
    /// ループ再生するか
    @AppStorage("isLoop") private var isLoop: Bool = false
    /// 再生する曲のタイプ
    /// oneSong | oneAlbum | allSongs | normal
    @AppStorage("playType") private var playType: String = "oneAlbum"
    
    /// プレーヤー
    @StateObject var playerViewModel: PlayerViewModel
    
    /// 曲名のスクロール
    @State var scrollText: Bool = false
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                
                Spacer()
                
                if let album = playerViewModel.currentAlbum {
                    URLDynamicImageView(viewModel: .init(url: album.coverUrl))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(minWidth: proxy.size.width - 16,
                               minHeight: proxy.size.width - 16)
                        .shadow(color: .black, radius: 12,
                                x: -4, y: 8)
                        .padding(.horizontal)
                        .offset(x: -4)
                    
                } else {
                    Image("disk")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(minWidth: proxy.size.width - 16,
                               minHeight: proxy.size.width - 16)
                        .shadow(color: .black, radius: 12,
                                x: -4, y: 8)
                        .padding(.horizontal)
                        .offset(x: -4)
                }
                
                
                HStack {
                    VStack(alignment: .leading) {
                        
                        Text(playerViewModel.currentSong?.name ?? "No data")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        
                        // アーティスト
                        Text(playerViewModel.currentSong?.artists.joined(separator: ", ") ?? "No data")
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
                //            Spacer()
                
                // スライダー
                Slider(value: Binding(
                    get: {
                        playerViewModel.elapsedTime
                    },
                    set: { newTime in
                        playerViewModel.seekTo(seconds: newTime)
                    }
                ),
                       in: 0...playerViewModel.duration)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                
                
                // ボタン系
                HStack(alignment: .center) {
                    // 前の曲
                    Button(action: {
                        playerViewModel.skipBackwards()
                    }, label: {
                        Image(systemName: "backward.end.fill")
                    })
                        .keyboardShortcut(.leftArrow, modifiers: [.shift])
                    
                    Spacer()
                    
                    // 再生、停止
                    Button(action: {
                        playerViewModel.togglePlayStop()
                    }, label: {
                        Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                    })
                        .keyboardShortcut(.space, modifiers: [])
                    
                    Spacer()
                    
                    // 次の曲
                    Button(action: {
                        playerViewModel.skipForward()
                    }, label: {
                        Image(systemName: "forward.end.fill")
                    })
                        .keyboardShortcut(.rightArrow, modifiers: [.shift])
                }
                .frame(height: 36)
                .padding(.horizontal)
//                .padding(.top, 8)
                .padding(.bottom, 12)
                .font(.system(size: 32))
                .foregroundColor(.white)
                
                // シャッフルとかループとかの設定
                HStack {
                    // シャッフルかどうか
                    Button(action: {
                        isShuffled.toggle()
                        playerViewModel.updatePlayType()    // キューの再生成
                    }, label: {
                        Image(systemName: "shuffle")
                            .foregroundColor(isShuffled ? .accentColor : .white)
                    })
                    
                     Spacer()
                    
                    // ループのタイプ TODO: 再生タイプの変更後、キューの再生成を行うように？
                    Button(action: {
                        playerViewModel.updatePlayType(type: playType)
                    }, label: {
                        Image(systemName:
                                { switch playType {
                                case "oneSong":
                                    return "repeat.1"
                                case "oneAlbum":
                                    return "repeat"
                                case "allSongs":
                                    return "infinity"
                                default:
                                    return "repeat"
                                }}()
                        )
                            .foregroundColor(isLoop ? .accentColor : .white)
                    })
                }
                .frame(height: 32)
                .padding(.horizontal)
                .padding(.bottom, 32)
                .font(.system(size: 28))
            }
        }
    }
}

