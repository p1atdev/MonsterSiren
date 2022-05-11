//
//  SongsList.swift
//  MonsterSiren
//
//  Created by p1atdev on 2021/11/06.
//

import SwiftUI

struct SongsList: View {
    
    /// 表示中のアルバム
    @Binding var album: Album?
    
    /// アルバムの曲一覧
    @Binding var songs: [Song]?
    
    /// アルバム詳細
    @Binding var albumDetail: AlbumDetail?
    
    /// プレーヤー
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    /// ホバー状態の曲
    @State private var overSong: Song?
    
    /// ロードが完了したか
    @Binding var loaded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let songs = songs {
                ForEach(0..<songs.count) { index in
                    let song = songs.sorted(by: {
                        $0.id < $1.id
                    })[index]
                    
                    Button(action: {
                        Task {
                            // 曲を再生する
                            await playerViewModel.play(song: song, albumDetail: albumDetail)
                        }
                        
                    }, label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(
                                    overSong?.id == song.id
                                    ? Color(.gray).opacity(0.4)
                                    : playerViewModel.currentSong?.id == song.id
                                    ? Color(.white).opacity(0.1)
                                    : Color(.clear)
                                )
                                .contentShape(Rectangle())
                            
                            HStack {
                                
                                // 再生中は再生中のマークにする
                                if playerViewModel.currentSong?.id == song.id {
                                    Image(systemName: "music.note")
                                        .frame(width: 24, height: 24)
                                        .font(.title)
                                        .padding()
                                } else
                                // ホバー中は再生ボタンを出す
                                if overSong?.id == song.id {
                                    Image(systemName: "play.fill")
                                        .frame(width: 24, height: 24)
                                        .font(.title)
                                        .padding()
                                } else {
                                    Text(String(index+1))
                                        .fixedSize()
                                        .frame(width: 24, height: 24)
                                        .font(.title.bold())
                                        .padding()
                                    
                                }
                                
                                GeometryReader { proxy in
                                    VStack(alignment: .leading) {
                                        
                                        ScrollSongText(songName: Binding.constant(song.name),
                                                       fontSize: 20,
                                                       wrapWidth: proxy.size.width)
                                        
                                        Text(song.artistes.joined(separator: ", "))
                                            .font(.system(size: 16))
                                            .opacity(0.8)
                                    }
                                }
                                
                                Spacer()
                                
                                Image("rhodes")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                    .opacity(0.4)
                            }
                            .padding()
                        }
                        .foregroundColor(playerViewModel.currentSong?.id == song.id ? .accentColor : .white)
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
}

