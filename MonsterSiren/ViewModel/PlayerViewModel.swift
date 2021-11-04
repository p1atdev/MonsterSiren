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
            print("曲の長さ: ", duration, "秒")
            self.duration = duration
        }
        
        _ = SAPlayer.Updates.ElapsedTime.subscribe { [weak self] elapsedTime in
            guard let self = self else { return }
//            print("ElapsedTime: ", elapsedTime)
            self.elapsedTime = elapsedTime
        }
        
//        _ = SAPlayer.Updates.AudioQueue.subscribe { url in
//            print("AudioQueue: ", url)
//
//        }
        
        _ = SAPlayer.Updates.PlayingStatus.subscribe { status in
            print(status)
            switch status {
            case .paused:
                self.isPlaying = false
            case .playing:
                self.isPlaying = true
            case .ended:
                // 再生終了時、もしループが有効ならばキューを再生成して自動で続行する
                
                // 次に再生される曲
                
                guard let lastSongData = self.playQueue.fullSongsQueue.filter({$0.value.songId == self.currentSong!.id }).first else { return }
                
                // keyを取得して、次の曲を再生、もしなかった場合で場合分け
                if let nextSong = self.playQueue.fullSongsQueue[lastSongData.key + 1] {
                    // プレーヤーの情報を更新する
                    self.currentSong = nextSong.songDetail
                    self.currentAlbum = nextSong.albumDetail
                    
                } else {
                    // これ以上曲はないので、頭から始める
                    // ループでなければ終了
                    if !self.isLoop {
                        self.elapsedTime = 0
                        return
                    }
                    
                    // もしシャッフルするなら
                    if self.isShuffled {
                        self.playQueue.shuffleQueue()
                    }
                    
                    // 現在の曲とアルバムをセット
                    self.currentSong = self.playQueue.fullSongsQueue[0]?.songDetail
                    self.currentAlbum = self.playQueue.fullSongsQueue[0]?.albumDetail
                    
                    print(self.playQueue.fullSongsQueue)
                }
                // 再生
                self.play()
                
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
                        let fullSongData = FullSongData(songDetail: currentSong, albumDetail: album)
                        // 情報のセット
                        SAPlayer.shared.mediaInfo = fullSongData.lockScreenParameter
                        
                        // キューをリセット
                        self.playQueue.fullSongsQueue = [:]
                        
                        // キューに追加
                        self.playQueue.fullSongsQueue[0] = fullSongData
                        
                        // キューを生成する
                        self.playQueue.genereteQueue(currentSong: song, albumDetail: album)
                    }
                }
            }
        })
        
    }
    
    /// 再生
    func play() {
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
                let fullSongData = FullSongData(songDetail: currentSong, albumDetail: currentAlbum!)
                // 情報のセット
                SAPlayer.shared.mediaInfo = fullSongData.lockScreenParameter
            }
        }
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
    
    /// playTypeを更新する
    func updatePlayType(type: String? = nil) {
        // typeを更新
        if let type = type {
            switch type {
            case "oneSong":
                playType = PlayType.oneAlbum.rawValue
                isLoop = true
            case "oneAlbum":
                playType = PlayType.allSongs.rawValue
                isLoop = true
            case "allSongs":
                playType = PlayType.normal.rawValue
                isLoop = false
            case "normal":
                playType = PlayType.oneSong.rawValue
                isLoop = true
            default:
                playType = PlayType.oneSong.rawValue
            }
        }
    
        guard let currentSong = currentSong else { return }
        guard let currentAlbum = currentAlbum else { return }
        
        playQueue.updateQueue(currentSong: currentSong, albumDetail: currentAlbum)
    }
    
    /// 現在のplayTypeをenumで返す
    func getPlayType() -> PlayType {
        switch playType {
        case "oneSong": return .oneSong
        case "oneAlbum": return .oneAlbum
        case "allSongs":  return  .allSongs
        case "normal": return .normal
        default: return .normal
        }
    }
}

enum PlayType: String {
    case oneSong = "oneSong"
    case oneAlbum = "oneAlbum"
    case allSongs = "allSongs"
    case normal = "normal"
}
