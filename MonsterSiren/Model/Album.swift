//
//  Album.swift.swift
//  Album.swift
//
//  Created by p1atdev on 2021/11/02.
//

import Foundation
import SwiftAudioPlayer
import UIKit

struct AlbumsData: Codable, Identifiable {
    var id: String = UUID().uuidString
    var code: Int
    var message: String
    var albums: [Album]
    
    enum CodingKeys: String, CodingKey {
        case code,
             message = "msg",
             albums = "data"
    }
}

struct Album: Codable, Identifiable {
    var id: String
    var name: String
    /// アルバムジャケット
    var coverUrl: String
    var artistes: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "cid",
             name,
             coverUrl,
             artistes
    }
    
    /// AlbumDetailを取得する
    func getDetail(completion: @escaping (AlbumDetail?) -> Void) {
        
        guard let url = URL(string: "https://monster-siren.hypergryph.com/api/album/\(id)/detail") else { return }
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let albumDetail = data {
                    let decodedData = try JSONDecoder().decode(AlbumDetailData.self, from: albumDetail)
                    completion(decodedData.data)
                    
                } else {
                    print("No data: Album.getDetail,", data as Any)
                    completion(nil)
                }
            } catch {
                print("Error:  Album.getDetail,", error)
                completion(nil)
            }
        }
        .resume()
    }
    
    /// idを指定してdetailを取得
    static func getDetail(id: String, completion: @escaping (AlbumDetail?) -> Void) {
        
        guard let url = URL(string: "https://monster-siren.hypergryph.com/api/album/\(id)/detail") else { return }
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let albumDetail = data {
                    let decodedData = try JSONDecoder().decode(AlbumDetailData.self, from: albumDetail)
                    completion(decodedData.data)
                    
                } else {
                    print("No data: Album.getDetail,", data as Any)
                    completion(nil)
                }
            } catch {
                print("Error:  Album.getDetail,", error)
                completion(nil)
            }
        }
        .resume()
    }
    
}

struct AlbumDetailData: Codable {
    var code: Int
    var message: String
    var data: AlbumDetail
    
    enum CodingKeys: String, CodingKey {
     case code,
          message = "msg",
          data
    }
}

struct AlbumDetail: Codable, Identifiable {
    var id: String
    var name: String
    var intro: String
    var belong: String
    /// アルバムジャケット
    var coverUrl: String
    /// ヘッダー画像
    var coverDeUrl: String
    var songs: [Song]
    
    enum CodingKeys: String, CodingKey {
        case id = "cid",
             name,
             intro,
             belong,
             coverUrl,
             coverDeUrl,
             songs
    }
}


struct Song: Codable, Identifiable {
    var id: String
    var name: String
    var artistes: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "cid",
             name,
             artistes
    }
    
    // SongDetail を取得する
    func getDetail(completion: @escaping (SongDetail?) -> Void) {
        guard let url = URL(string: "https://monster-siren.hypergryph.com/api/song/\(id)") else { return }
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let songDetailData = data {
                    let decodedData = try JSONDecoder().decode(SongDetailData.self, from: songDetailData)
                    DispatchQueue.main.async {
                        completion(decodedData.data)
                    }
                } else {
                    print("No data: Song.getDetail,", data as Any)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("Error: Song.getDetail,", error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        .resume()
    }
}

struct SongDetailData: Codable {
    var code: Int
    var msg: String
    var data: SongDetail
    
    enum CondingKeys: String, CodingKey {
        case code,
             msg,
             data
    }
}

struct SongDetail: Codable, Identifiable {
    var id: String
    var name: String
    var albumCid: String
    var sourceUrl: String
    var lyricUrl: String?
    var mvUrl: String?
    var mvCoverUrl: String?
    var artists: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "cid",
             name,
             albumCid,
             sourceUrl,
             lyricUrl,
             mvUrl,
             mvCoverUrl,
             artists
    }
    
    /// Songに変換したやつ
    func convertToSong() -> Song {
        return Song(id: id, name: name, artistes: artists)
    }
}

struct AllSongs: Codable {
    var code: Int
    var msg: String
    var data: AllSongsData
    
    enum CodingKeys: String, CodingKey {
        case code,
             msg,
             data
    }
}

struct AllSongsData: Codable {
    var list: [AllSongsDataSong]
    var autoplay: Bool?
    
    enum CodinKeys: String, CodingKey {
        case list,
             autoplay
    }
}

struct AllSongsDataSong: Codable {
    var id: String
    var name: String
    var albumCid: String
    var artists: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "cid",
             name,
             albumCid,
             artists
    }
    
    func convertToSong() -> Song {
        return Song(id: id, name: name, artistes: artists)
    }
}

struct FullSongData {
    var songId: String
    var albumId: String
    var songName: String
    var albumName: String
    
    /// 音源
    var sourceUrl: String
    /// 歌詞
    var lyricUrl: String?
    var mvUrl: String?
    var mvCoverUrl: String?
    var artists: [String]
    
    /// アルバムの画像
    var coverUrl: String
    /// バナーの画像
    var coverDeUrl: String
    
    var songDetail: SongDetail
    var albumDetail: AlbumDetail
    
    init(songDetail song: SongDetail, albumDetail album: AlbumDetail) {
        self.songId = song.id
        self.albumId = album.id
        self.songName = song.name
        self.albumName = album.name
        self.sourceUrl = song.sourceUrl
        self.lyricUrl = song.lyricUrl
        self.mvUrl = song.mvUrl
        self.mvCoverUrl = song.mvCoverUrl
        self.artists = song.artists
        self.coverUrl = album.coverUrl
        self.coverDeUrl = album.coverDeUrl
        
        self.songDetail = song
        self.albumDetail = album
    }
    
    // ロック画面用のやつを生成する
    var lockScreenParameter: SALockScreenInfo {
        return .init(title: self.songName,
                     artist: self.artists.joined(separator: ", "),
                     albumTitle: self.albumName,
                     artwork: UIImage(url: self.coverUrl),
                     releaseDate: Int(URL(string: self.sourceUrl)!.pathComponents[5])!)
    }
}
