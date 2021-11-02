//
//  PlayQueue.swift
//  PlayQueue
//
//  Created by 周廷叡 on 2021/11/03.
//

import SwiftUI

///// 再生待ちリスト
struct PlayQueue {
    /// シャッフルするか
    @AppStorage("isShuffled") private var isShuffled: Bool = false
    /// ループ再生するか
    @AppStorage("isLoop") private var isLoop: Bool = false
    /// 再生する曲のタイプ
    /// oneSong | oneAlbum | allSongs
    @AppStorage("playType") private var playType: String = "oneSong"
    
    /// これから再生することになる曲リスト([Song])
    /// 今再生している曲は含まない
    @State var songsQueue: [Song] = []
    
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
}
