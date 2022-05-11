//
//  PlayerViewModel.swift
//  PlayerViewModel
//
//  Created by p1atdev on 2021/11/02.
//

import Foundation
import SwiftUI
import SwiftAudioEx
import MediaPlayer

class PlayerViewModel: ObservableObject {
    
    /// プレーヤー
    @Published var player = QueuedAudioPlayer()
    
    /// シャッフルするか
    @AppStorage("isShuffled") private var isShuffled: Bool = false
    /// ループ再生するか
    @AppStorage("isLoop") private var isLoop: Bool = false
    /// 再生する曲のタイプ
    /// oneSong | oneAlbum | allSongs
    @AppStorage("playType") private var playType: String = "oneAlbum"
    /// 音量
    @AppStorage("musicVolume") private var volume: Double = 1.0
    
    /// 現在再生されている曲
    @Published var currentSong: SongDetail?
    
    /// 曲のアルバム
    @Published var currentAlbum: AlbumDetail?
    
    /// 曲の総時間
    @Published var duration: Double = 1.0
    
    /// 再生の進捗(秒)
    @Published var elapsedTime: Double = 0.0
    
    /// 現在再生しているか
    @Published var isPlaying: Bool = false
    
    /// 歌詞を表示するか
    @Published var shouldShowLyrics: Bool = false
    
    /// 全ての曲のSongDetail
    var allSongDetails: [SongDetail] = []
    
    /// 曲のキュー管理
    var playQueue = PlayQueue()
    
    init() {
        
        // 経過時間
        self.player.event.secondElapse.addListener(self, handleElapsedTimeChange)
        
        // duration変化
        self.player.event.updateDuration.addListener(self, handleDurationChange)
        
        // 再生状態変化
        self.player.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        
        // playbackの終了
        self.player.event.playbackEnd.addListener(self, handlePlaybackEnd)
        
        
        self.player.remoteCommands = [
            .pause,
            .play,
            .togglePlayPause,
            .next,
            .previous,
            .skipForward(preferredIntervals: [30]),
            .skipBackward(preferredIntervals: [30]),
            .stop
        ]
        
        // ループ再生
        self.player.repeatMode = self.isLoop ? .queue : .off
        
        // カバー画像などの目的で全曲取得
        Task {
            let details = await self.getAllSongDetails()
            self.allSongDetails = details
        }
        
        // リモートコマンド？
        try? AudioSessionController.shared.set(category: .playback)
        //...
        // You should wait with activating the session until you actually start playback of audio.
        // This is to avoid interrupting other audio without the need to do it.
        try? AudioSessionController.shared.activateSession()
    }

    /// 再生
    /// async
    func play(song: Song, albumDetail album: AlbumDetail?) async {
        
        // キューをクリア
        self.player.removeUpcomingItems()
        
        print("[*] 以降の曲", self.player.nextItems)
        
        // アルバムの詳細を手に入れる
        withAnimation {
            currentAlbum = album
        }
        
        if let detail = await song.getDetail() {
            DispatchQueue.main.async {
                withAnimation {
                    self.currentSong = detail
                }
                
                //曲のurl
                if let currentSong = self.currentSong {
                    let songUrl = currentSong.sourceUrl
                    if let url = URL(string: songUrl) {
                        
                        do {
                            if let album = album {
                                let audioItem = DefaultAudioItem(audioUrl: url.absoluteString,
                                                                 artist: song.artistes.joined(separator: ", "),
                                                                 title: song.name,
                                                                 albumTitle: album.name,
                                                                 sourceType: .stream,
                                                                 artwork: UIImage(url: album.coverUrl))
                                try self.player.load(item: audioItem, playWhenReady: true)
                            } else {
                                let audioItem = DefaultAudioItem(audioUrl: url.absoluteString,
                                                                 artist: song.artistes.joined(separator: ", "),
                                                                 title: song.name,
                                                                 sourceType: .stream)
                                try self.player.load(item: audioItem, playWhenReady: true)
                            }
                            
                            self.changeVolume(self.volume)
                        } catch {
                            print("[*] play error:", error)
                        }
                        
                        
                        withAnimation {
                            self.elapsedTime = 0
                        }
                        
                        // ロック画面での表示の設定、キューの生成
                        if let album = album {
                            let fullSongData = FullSongData(songDetail: currentSong, albumDetail: album)
                            // 情報のセット
                            self.setMediaInfo(fullSongData)
                            
                            Task {
                                // キューを生成する
                                await self.createQueueWith(currentSong: detail, albumDetail: album)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    /// 再生と停止を切り替え
    func togglePlayStop() {
        self.player.togglePlaying()
    }
    
    /// ロック画面とかでの表示をセット
    func setMediaInfo(_ songData: FullSongData) {
        
        let artwork = UIImage(url: songData.coverUrl)
        
        self.player.nowPlayingInfoController.set(keyValues: [
            MediaItemProperty.duration(self.duration),
            MediaItemProperty.artist(songData.artists.joined(separator: ", ")),
            MediaItemProperty.artwork(MPMediaItemArtwork(boundsSize: artwork.size,
                                                         requestHandler: { size -> UIImage in
                                                             return artwork
                                                         })),
            MediaItemProperty.title(songData.songName),
            MediaItemProperty.albumTitle(songData.albumName),
        ])
    }
    
    /// 次の曲にする
    func skipToNext() {
        do {
            // 次の曲へ
            try self.player.next()
            print("[*] スキップ")
        } catch {
            // 次の曲はないので何もしない
            print("[*] スキップしようとしたが曲がないので何もしない")
        }
    }
    
    /// 前の曲にする
    func skipToPrevious() {
        do {
            // 次の曲へ
            try self.player.previous()
            print("[*] 戻る")
        } catch {
            // 次の曲はないので何もしない
            print("[*] 戻ろうとしたが曲がないので何もしない")
        }
    }
    
    /// 再生位置を変更する
    func seekTo(seconds: Double) {
        self.player.seek(to: seconds)
    }
    
    /// playTypeを更新する
    func updatePlayType(type: String? = nil) {
        // typeを更新
        if let type = type {
            switch type {
            case "oneAlbum":
                // 一曲リピートに
                playType = PlayType.oneSong.rawValue
                isLoop = true
                self.player.repeatMode = .queue
            case "oneSong":
                // 全曲リピートに
                playType = PlayType.allSongs.rawValue
                isLoop = true
                self.player.repeatMode = .queue
            case "allSongs":
                // 通常に戻す
                playType = PlayType.normal.rawValue
                isLoop = false
                self.player.repeatMode = .off
            case "normal":
                // アルバムリピートに
                playType = PlayType.oneAlbum.rawValue
                isLoop = true
                self.player.repeatMode = .queue
            default:
                playType = PlayType.normal.rawValue
                self.player.repeatMode = .off
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
    
    /// 音量を変更する
    func changeVolume(_ volume: Double) {
        self.player.volume = Float(volume)
        DispatchQueue.main.async {
            self.volume = volume
        }
    }
    
    /// アルバムをもらってキューに追加する
    func createQueueWith(currentSong song: SongDetail, albumDetail album: AlbumDetail) async {
        switch self.playType {
        case "oneSong":
            print("[*] 曲のキューを作成")
            
            break
        case "oneAlbum":
            print("[*] アルバムの再生キューを作成")
            let songs = await getSongsFrom(albumDetail: album, startSong: song.convertToSong())
            
            print("[*] songs:", songs)
            
            // キューに追加
            let audioItems = songs.map { song -> AudioItem in
                let item = DefaultAudioItem(audioUrl: song.sourceUrl,
                                            artist: song.artists.joined(separator: ", "),
                                            title: song.name,
                                            albumTitle: album.name,
                                            sourceType: .stream,
                                            artwork: UIImage(url: album.coverUrl))
                return item
            }
            
            try? self.player.add(items: audioItems, playWhenReady: true)
            
//            print("[*] 次の曲:", self.player.nextItems)
//            print("[*] 次の曲の数:", self.player.nextItems.count)
            print("[*] リピートモード", self.player.repeatMode)
            
            break
        case "allSongs":
            print("[*] 全ての曲の再生キューを作成")
//            isNotNecessaryToUpdateQueue = true
//            self.getAllSongs(currentSong: song, completion: { allSongs in
//                self.songsQueue = allSongs ?? []
//
//                // シャッフルが必要ならシャッフル
//                self.shuffleIfneeded()
//                // キューを更新
//                self.updateQueue()
//
//                print("キュー更新開始")
//            })
            break
        case "normal":
            print("[*] 当該曲のキューを作成")
            break
        default:
            break
        }
    }
    
    
    /// アルバムと開始曲から再生順に曲を返す
    private func getSongsFrom(albumDetail album: AlbumDetail, startSong start: Song) async -> [SongDetail] {
        if self.isShuffled {
            // 開始曲を除いて
            let songs = album.songs.filter({$0.id != start.id}).shuffled()
            
            var songDetails: [Int: SongDetail] = [:]
            
            await withTaskGroup(of: (Int, SongDetail?).self) { group in
                for (index, song) in songs.enumerated() {
                    group.addTask {
                        return (index, await song.getDetail())
                    }
                }
                
                // 子タスクから結果を完了した順に逐一取得する
                for await (index, songDetail) in group {
                    songDetails[index] = songDetail
                }
            }
            
            return songDetails.sorted(by: { $0.key < $1.key }).map({ $0.value })
            
        } else {
            // 曲を出して
            var songs = album.songs.sorted(by: {$0.id < $1.id})
            
            // 開始曲の位置を割り出して、前を後ろに連結
            guard let startSongIndex = songs.firstIndex(where: {$0.id == start.id}) else { return [] }
            
            songs = (songs.suffix(songs.count - (startSongIndex + 1)) + songs.prefix(startSongIndex))
            
            var songDetails: [Int: SongDetail] = [:]
            
            await withTaskGroup(of: (Int, SongDetail?).self) { group in
                for (index, song) in songs.enumerated() {
                    group.addTask {
                        return (index, await song.getDetail())
                    }
                }
                
                // 子タスクから結果を完了した順に逐一取得する
                for await (index, songDetail) in group {
                    songDetails[index] = songDetail
                }
            }
            
            print("[*] songDetails:", songDetails)
            
            // 返す
            return songDetails.sorted(by: { $0.key < $1.key }).map({ $0.value })
        }
    }
    
    
    /// 全ての曲のSongDetailを取得
    func getAllSongDetails() async -> [SongDetail] {
        guard let endpoint = URL(string: "https://monster-siren.hypergryph.com/api/songs") else { return [] }
        
        do {
            
            let (data, _) = try await URLSession.shared.data(from: endpoint)
            
            let decodedData = try JSONDecoder().decode(AllSongs.self, from: data)
            let songs = decodedData.data.list.sorted(by: { // アルバムidと曲idでソート
                if $0.albumCid == $1.albumCid {
                    return $0.id < $1.id
                } else {
                    return $0.albumCid < $1.albumCid
                }
            }).map({    // Songに変換
                $0.convertToSong()
            })
            
            var songDetails: [Int: SongDetail] = [:]
            
            await withTaskGroup(of: (Int, SongDetail?).self) { group in
                for (index, song) in songs.enumerated() {
                    group.addTask {
                        return (index, await song.getDetail())
                    }
                }
                for await (index, song) in group {
                    songDetails[index] = song
                }
            }
            
            let convertedSongDetails = songDetails.sorted(by: { $0.key < $1.key }).map({ $0.value })
            
            return convertedSongDetails
            
        } catch {
            print("[*] 全曲取得失敗")
            return []
        }
    }
    
    /// Audioイベントハンドル
    private func handleAudioPlayerStateChange(state: AudioPlayerState) {
        switch (state) {
        case .playing:
            print("[*] playing")
            print("[*] リピートモード", self.player.repeatMode)
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        case .buffering:
            print("[*] buffering")
        case .idle:
            print("[*] idle")
        case .loading:
            print("[*] loading")
        case .paused:
            print("[*] paused")
            DispatchQueue.main.async {
                self.isPlaying = false
            }
        case .ready:
            print("[*] ready")
        }
    }
    
    /// durationの変化のハンドル
    private func handleDurationChange(duration: Double) {
        DispatchQueue.main.async {
            self.duration = duration
        }
        print("[*] 曲の総時間:", duration)
    }
    
    /// 再生秒の変化のハンドル
    private func handleElapsedTimeChange(time: TimeInterval) {
        DispatchQueue.main.async {
            self.elapsedTime = time
        }
    }
    
    /// 再生終了？ハンドル
    private func handlePlaybackEnd(reason: PlaybackEndedReason) {
        
        switch reason {
        case .playedUntilEnd:
            print("[*] 最後まで再生された")
            break
        case .playerStopped:
            print("[*] 再生停止された")
            break
        case .skippedToNext:
            print("[*] 次の曲にスキップされた")
            
            break
        case .skippedToPrevious:
            print("[*] 前の曲にスキップされた")
            break
        case .jumpedToIndex:
            print("[*] 場所指定でジャンプされた")
            break
        }
        
        print("[*] 現在の曲:", self.player.currentItem?.getTitle())
        print("[*] 現在のインデックス:", self.player.currentIndex)
        print("[*] 以降の曲", self.player.nextItems)
        
        // アルバムとかの表示の切り替え
        Task {
            guard let currentSongDetail = allSongDetails.first(where: { $0.name == self.player.currentItem?.getTitle() }) else {
                return
            }
            
            guard let currentAlbumDetail = await AlbumDetail.fetch(id: currentSongDetail.albumCid) else { return }
            
            DispatchQueue.main.async {
                // currentを更新
                withAnimation {
                    self.currentSong = currentSongDetail
                    self.currentAlbum = currentAlbumDetail
                }
            }
        }
        
    }
}

enum PlayType: String {
    case oneSong = "oneSong"
    case oneAlbum = "oneAlbum"
    case allSongs = "allSongs"
    case normal = "normal"
}
