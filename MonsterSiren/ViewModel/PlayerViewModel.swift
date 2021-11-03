//
//  PlayerViewModel.swift
//  PlayerViewModel
//
//  Created by p1atdev on 2021/11/02.
//

import Foundation
import SwiftUI
import SwiftAudioPlayer

class PlayerViewModel: ObservableObject {
    
    /// 現在再生されている曲
    @Published var currentSong: SongDetail?
    
    /// 曲のアルバム
    @Published var currentAlbum: AlbumDetail?
    
    /// 再生の進捗(%)
    @Published var progress: Double = 0
    
    var playQueue = PlayQueue()
    
    
    func play(song: Song, albumDetail album: AlbumDetail?) {
        // アルバムの詳細を手に入れる
        withAnimation {
            currentAlbum = album
        }
        
        // まずは曲の詳細を手に入れる
        song.getDetail(completion: { detail in
                withAnimation {
                    self.currentSong = detail
                }
            
            //曲のurl
            if let currentSong = self.currentSong {
                let songUrl = currentSong.sourceUrl
                if let url = URL(string: songUrl) {
                    // 再生する
                    SAPlayer.shared.startRemoteAudio(withRemoteUrl: url)
                    SAPlayer.shared.play()
                    
                    // ロック画面での表示の設定、キューの生成
                    if let album = album {
                        // 情報のセット
                        let info = SALockScreenInfo(title: currentSong.name,
                                                    artist: currentSong.artists.joined(separator: ", "),
                                                    albumTitle: album.name,
                                                    artwork: UIImage(url: album.coverUrl),
                                                    releaseDate: Int(url.pathComponents[5])!)
                        SAPlayer.shared.mediaInfo = info
                        
                        // キューを生成する
                        self.playQueue.genereteQueue(currentSong: song, albumDetail: album)
                    }
                }
            }
        })
        
    }
    
    func stop() {
        
    }
    
    func resume() {
        
    }
}
