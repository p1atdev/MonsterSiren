//
//  PlayQueue.swift
//  PlayQueue
//
//  Created by p1atdev on 2021/11/03.
//

import SwiftUI
import SwiftAudioPlayer

///// 再生待ちリスト
class PlayQueue {
    /// シャッフルするか
    @AppStorage("isShuffled") private var isShuffled: Bool = false
    /// ループ再生するか
    @AppStorage("isLoop") private var isLoop: Bool = false
    /// 再生する曲のタイプ
    /// oneSong | oneAlbum | allSongs
    @AppStorage("playType") private var playType: String = "oneAlbum"
    
    /// これから再生することになる曲リスト([Song])
    /// 今再生している曲は含まない
    var songsQueue: [Song] = []
    
    /// 詳細を含んだリスト
    var fullSongsQueue: [FullSongData] = []
    
    /// 生成する
    func genereteQueue(currentSong song: Song ,albumDetail album: AlbumDetail) {
        
        // 曲の取得
        switch playType {
        case "oneSong":
            songsQueue = [song]
        case "oneAlbum":
            songsQueue = album.songs
        case "allSongs":
            getAllSongs(completion: { allSongs in
                self.songsQueue = allSongs ?? []
            })
        default:
            break
        }
        
        // シャッフルするならシャッフル
        if isShuffled {
            songsQueue = songsQueue.shuffled()
        }
        
        // キューを更新
        DispatchQueue.global().async {
            self.updateQueue()
        }
        
    }
    
    /// 生成する
    func genereteQueue(albumDetail album: AlbumDetail) {
        // 曲の取得
        switch playType {
            // もし一曲だけの場合はそのまま継続なので何もしない？
        case "oneAlbum":
            songsQueue = album.songs
        case "allSongs":
            getAllSongs(completion: { allSongs in
                self.songsQueue = allSongs ?? []
            })
        default:
            break
        }
        
        // シャッフルするならシャッフル
        if isShuffled {
            songsQueue = songsQueue.shuffled()
        }
        
        // キューを更新
        DispatchQueue.global().async {
            self.updateQueue()
        }
        
    }
    
    /// 全てのsongを取得する
    private func getAllSongs(completion: @escaping ([Song]?) -> Void) {
        guard let url = URL(string: "https://monster-siren.hypergryph.com/api/songs") else { return }
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let allSongs = data {
                    let decodedData = try JSONDecoder().decode(AllSongs.self, from: allSongs)
                    completion(decodedData.data)
                    
                } else {
                    print("No data: getAllSongs,", data as Any)
                    completion(nil)
                }
            } catch {
                print("Error: getAllSongs,", error)
                completion(nil)
            }
        }
        .resume()
    }

    /// songをqueueにぶち込む
    private func updateQueue() {
        // まずは消して
        SAPlayer.shared.audioQueued = []
        fullSongsQueue = []
        
        for song in songsQueue {
            guard let url = URL(string: "https://monster-siren.hypergryph.com/api/song/\(song.id)") else { return }
            
            URLSession.shared.dataTask(with: url) {(data, response, error) in
                do {
                    guard let songDetailData = data else {
                        print("No data: updateQueue,", data as Any)
                        return
                    }
                    
                    let songDetail = (try JSONDecoder().decode(SongDetailData.self, from: songDetailData)).data
                    
                    let songUrl = songDetail.sourceUrl
                    
                    // アートワークも取得する
                    let albumId = songDetail.albumCid
                    
                    Album.getDetail(id: albumId) { albumDetail in
                        guard let albumDetail: AlbumDetail = albumDetail else { return }
                        guard let songUrl: URL = URL(string: songUrl) else { return }
                        
                        /// 全ての曲情報が詰まったデータ
                        let fullSongData = FullSongData(songDetail: songDetail,
                                                        albumDetail: albumDetail)
                        
                        // ロック画面に表示されるやつをセットする
                        SAPlayer.shared.queueRemoteAudio(withRemoteUrl: songUrl,
                                                         mediaInfo: fullSongData.lockScreenParameter)
                        
                        // キューに保存する
                        self.fullSongsQueue.append(fullSongData)
                    }
                } catch {
                    print("Error: updateQueue,", error)
                }
            }
            .resume()
        }
        
    }
}
