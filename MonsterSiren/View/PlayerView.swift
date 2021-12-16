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
    /// 音量
    @AppStorage("musicVolume") private var volume: Double = 1.0
    
    /// プレーヤー
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    /// 曲名のスクロール
    @State var scrollText: Bool = false
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                
                Spacer()
                
                if let album = playerViewModel.currentAlbum {
                    ZStack(alignment: .topLeading) {
                        URLDynamicImageView(viewModel: .init(url: album.coverUrl))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(minWidth: proxy.size.width - 16,
                                   minHeight: proxy.size.width - 16)
                            .shadow(color: .black, radius: 12,
                                    x: -4, y: 8)
                        
                        // もし歌詞のURLがあれば表示する
                        if playerViewModel.currentSong?.lyricUrl != nil {
                            Button(action: {
                                // 歌詞のボタンが押された
                                // 歌詞の表示処理
                                withAnimation {
                                    playerViewModel.shouldShowLyrics.toggle()
                                }
                            }, label: {
                                ZStack {
                                    Rectangle()
                                        .background(Color("AccentColor"))
                                    Image(systemName: "text.quote")
                                        .blendMode(.destinationOut)
                                }
                                .compositingGroup()
                                .shadow(color: .black.opacity(0.3),
                                        radius: 4,
                                        x: -1,
                                        y: 2)
                            })
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: 40, height: 40)
                                .padding(4)
                        }
                        
                    }
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
                
                
                // 曲のスライダー
                HStack {
                    Image(systemName: "music.note")
                        .frame(width: 36)
                    
                    Slider(value: Binding(
                        get: {
                            playerViewModel.elapsedTime
                        },
                        set: { newTime in
                            playerViewModel.seekTo(seconds: newTime)
                        }
                    ),
                           in: 0...playerViewModel.duration)
                }
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
                .padding(.bottom, 12)
                .font(.system(size: 28))
                
                // 音量のスライダー
                HStack {
                    // スピーカーのアイコン
                    Image(systemName: {
                        if volume == 0.0 {
                            return "speaker.fill"
                        } else if volume <= 0.2 {
                            return "speaker.wave.1.fill"
                        } else if volume <= 0.6 {
                            return "speaker.wave.2.fill"
                        } else {
                            return "speaker.wave.3.fill"
                        }
                    }())
                        .frame(width: 36)
                    
                    Slider(value: Binding(
                        get: {
                            volume
                        }, set: { value in
                            playerViewModel.changeVolume(value)
                        }),
                           in: 0.0...1.0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: Binding(get: {
            playerViewModel.shouldShowLyrics && window.width <= 750
        }, set: {
            playerViewModel.shouldShowLyrics = $0
        })) {
            // 歌詞の画面表示
            LyricsView()
        }
    }
}

