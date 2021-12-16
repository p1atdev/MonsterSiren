//
//  LyricsView.swift
//  MonsterSiren
//
//  Created by 周廷叡 on 2021/12/16.
//

import SwiftUI

struct LyricsView: View {
    
    /// プレーヤーのやつ
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    /// 歌詞データ
    @StateObject var lyricsViewModel = LyricsViewModel()
    
    /// ハイライトする歌詞
    @State private var highlightedLyric: LyricsItem?
    
    /// 歌詞のとこにスクロールするかどうか
    @State private var shouldScrollToLyric: Bool = true
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 戻るボタン
            BackButton(onAction: {
                withAnimation {
                    playerViewModel.shouldShowLyrics.toggle()
                }
            })
                .zIndex(50)
            
            ScrollViewReader { scrollProxy in
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 64) {
                            // トップに行くための無のview
                            EmptyView()
                                .id("top")
                            
                            if let lyrics = lyricsViewModel.lyrics.lyrics {
                                ForEach(lyrics, id: \.time) { lyric in
                                    // 再生されてる箇所に合わせてスクロールを移動&文字のopcityを変更
                                    Text(lyric.text)
                                        .font(.largeTitle.bold())
                                        .frame(maxWidth: .infinity,
                                               alignment: .leading)
                                        .opacity(lyric.time == highlightedLyric?.time ? 1.0 : 0.5)
                                        .id(lyric.time)
                                    
                                    // TODO: 画面狭いときのよくわからん挙動(左右にぶれる)を修正したい
                                    
                                }
                                .onChange(of: playerViewModel.elapsedTime) { time in
                                    // TODO: もしどっかにスクロールしていた場合を除きたい(Spotifyみたいに )
                                    
                                    guard let lyric = lyrics.filter({
                                        $0.time <= playerViewModel.elapsedTime
                                    }).last else { return }
                                    
                                    // スクロール
                                    withAnimation {
                                        highlightedLyric = lyric
                                        
//                                        if shouldScrollToLyric {
                                        scrollProxy.scrollTo(lyric.time,
                                                             anchor: .center)
//                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, window.width > 750 ? 128 : 80)
                        .padding(.horizontal, window.width > 750 ? 64 : 20)
                    }
                    
                    // TODO: トラックパッドのジェスチャーの判定がようわからん
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                // ドラッグ中は歌詞に吸い付けられないように
//                                shouldScrollToLyric = false
//                            }
//                            .onEnded { value in
//                                print(value)
//                                // もし現在再生されているところから離れたところにドラッグしていたら歌詞が変化してもスクロールしないように
//                            }
//                    )
                    

                }
                // 曲が変わったときに歌詞を更新する
                .onChange(of: playerViewModel.currentSong?.id) { song in
                    // 歌詞を消す
                    lyricsViewModel.clearLyrics()
                    
                    // 一番上にスクロールする
                    scrollProxy.scrollTo("top")
                    
                    // 歌詞を取得
                    self.getLyrics()
                }
            
            }
            .mask(
                LinearGradient(
                    gradient: Gradient(
                        colors: [Color.black.opacity(0)]
                        + [Color](repeating: Color.black,
                                  count: 5)
                        + [Color.black.opacity(0)]
                    ),
                    startPoint: .top,
                    endPoint: .bottom)
            )
            
            if playerViewModel.currentSong?.lyricUrl == nil {
                Text("No lyrics data")
                    .font(.title.italic())
                    .opacity(0.5)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
            } else if lyricsViewModel.lyrics.lyrics == nil {
                Text("Loading lyrics data...")
                    .font(.title.italic())
                    .opacity(0.5)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
            }
            
        }
        .background(
            Image("background")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.9)
        )
        .onAppear(perform: {
            self.getLyrics()
        })
    }
    
    /// 現在の曲の歌詞を取得する
    private func getLyrics() {
        lyricsViewModel.fetchLyricsFrom(playerViewModel.currentSong?.lyricUrl)
    }
}
