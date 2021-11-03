//
//  PlayQueue.swift
//  PlayQueue
//
//  Created by 周廷叡 on 2021/11/03.
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
    var fullSongsQueue: Dictionary<Int, FullSongData> = [:]
    
    /// 生成する
    func genereteQueue(currentSong song: Song ,albumDetail album: AlbumDetail) {
        
        DispatchQueue.global().async {
            // 曲の取得
            switch self.playType {
            case "oneSong":
                self.songsQueue = [song]
            case "oneAlbum":
                self.songsQueue = album.songs
            case "allSongs":
                self.getAllSongs(completion: { allSongs in
                    self.songsQueue = allSongs ?? []
                })
            default:
                break
            }
            
            // シャッフルするならシャッフル
            if self.isShuffled {
                self.songsQueue = self.songsQueue.shuffled()
            }
            
            // キューを更新
            self.updateQueue()
            
            print("キュー更新完了")
        }
        
    }
    
    /// シャッフルする
    func shuffleQueue() {
        let random = (0..<fullSongsQueue.count).shuffled()
        let tmp = fullSongsQueue
        
        // シャッフル
        for i in 0..<fullSongsQueue.count {
            fullSongsQueue[i] = tmp[random[i]]
        }
    }
    
    /// 全てのsongを取得する
    private func getAllSongs(completion: @escaping ([Song]?) -> Void) {
        guard let url = URL(string: "https://monster-siren.hypergryph.com/api/songs") else { return }
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let allSongs = data {
                    let decodedData = try JSONDecoder().decode(AllSongs.self, from: allSongs)
                    completion(decodedData.data.list.map({ $0.convertToSong() }))
                    
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
        fullSongsQueue = [:]
        
        for (index, song) in songsQueue.enumerated() {
            guard let url = URL(string: "https://monster-siren.hypergryph.com/api/song/\(song.id)") else { return }
            
            URLSession.shared.dataTask(with: url) {(data, response, error) in
                do {
                    guard let songDetailData = data else {
                        print("No data: updateQueue,", data as Any)
                        return
                    }
                    
                    let songDetail = (try JSONDecoder().decode(SongDetailData.self, from: songDetailData)).data
                    
                    // アートワークも取得する
                    let albumId = songDetail.albumCid
                    
                    Album.getDetail(id: albumId) { albumDetail in
                        guard let albumDetail: AlbumDetail = albumDetail else { return }
                        
                        /// 全ての曲情報が詰まったデータ
                        let fullSongData = FullSongData(songDetail: songDetail,
                                                        albumDetail: albumDetail)
                        
                        // ロック画面に表示されるやつをセットする
//                        SAPlayer.shared.queueRemoteAudio(withRemoteUrl: songUrl,
//                                                         mediaInfo: fullSongData.lockScreenParameter)
//
                        // キューに保存する
                        self.fullSongsQueue[index + 1] = fullSongData
                    }
                } catch {
                    print("Error: updateQueue,", error)
                }
            }
            .resume()
            
        }
        
    }
}
