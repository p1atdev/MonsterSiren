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
    
    /// 曲の総時間
    @Published var duration: Double = 0.0
    
    /// 再生の進捗(秒)
    @Published var elapsedTime: Double = 0.0
    
    /// 現在再生しているか
    @Published var isPlaying: Bool = false
    
    var playQueue = PlayQueue()
    
    init() {
//        DispatchQueue.global().async {
        _ = SAPlayer.Updates.Duration.subscribe { duration in
            print("Duration: ", duration)
            self.duration = duration
        }
        
        _ = SAPlayer.Updates.ElapsedTime.subscribe { [weak self] elapsedTime in
            guard let self = self else { return }
//            print("ElapsedTime: ", elapsedTime)
            self.elapsedTime = elapsedTime
        }
        
        _ = SAPlayer.Updates.AudioQueue.subscribe { audioQueue in
            print("AudioQueue: ", audioQueue)
        }
    }
    
    
    /// 再生
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
                    
                    withAnimation {
                        self.isPlaying = true
                        self.elapsedTime = 0
                    }
                    
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
    
    /// 再生と停止を切り替え
    func togglePlayStop() {
        isPlaying.toggle()
        SAPlayer.shared.togglePlayAndPause()
    }
    
    /// 次の曲にする
    func skipForward() {
        SAPlayer.shared.skipForward()
    }
    
    /// 前の曲にする
    func skipBackwards() {
        SAPlayer.shared.skipBackwards()
    }
    
    /// 再生位置を変更する
    func seekTo(seconds: Double) {
        SAPlayer.shared.seekTo(seconds: seconds)
    }
}
