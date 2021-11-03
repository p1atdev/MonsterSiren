//
//  PlayerViewModel.swift
//  PlayerViewModel
//
//  Created by 周廷叡 on 2021/11/02.
//

import Foundation
import SwiftUI
import SwiftAudioPlayer

class PlayerViewModel: ObservableObject {
    
    /// シャッフルするか
    @AppStorage("isShuffled") private var isShuffled: Bool = false
    /// ループ再生するか
    @AppStorage("isLoop") private var isLoop: Bool = false
    /// 再生する曲のタイプ
    /// oneSong | oneAlbum | allSongs
    @AppStorage("playType") private var playType: String = "oneAlbum"
    
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
        
        _ = SAPlayer.Updates.AudioQueue.subscribe { url in
            print("AudioQueue: ", url)
            
            // 次に再生される曲
            guard let newSongData = self.playQueue.fullSongsQueue.filter({$0.sourceUrl == url.absoluteString }).first else { return }
            // プレーヤーの情報を更新する
            self.currentSong = newSongData.songDetail
            self.currentAlbum = newSongData.albumDetail
        }
        
        _ = SAPlayer.Updates.PlayingStatus.subscribe { status in
            switch status {
            case .paused:
                self.isPlaying = false
            case .playing:
                self.isPlaying = true
            case .ended:
                // 再生終了時、もしループが有効ならばキューを再生成して自動で続行
                if self.isLoop {
                    self.playQueue.genereteQueue(albumDetail: self.currentAlbum!)
                }
                
            default:
                break
            }
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
