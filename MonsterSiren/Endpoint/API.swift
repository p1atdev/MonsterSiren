//
//  API.swift
//  MonsterSiren
//
//  Created by p1atdev on 2022/06/16.
//

import Foundation
import Get

class MonsterSirenClient {
    let client = APIClient(baseURL: URL(string: "https://monster-siren.hypergryph.com/api"))
    
    /// get specific song
    func getSong(songId: String) async throws -> SongDetail {
        let songDetail: SongDetailData = try await client.send(.get("/song/\(songId)")).value
        
        return songDetail.data
    }
    
    private func _getSongs() async throws -> [Song] {
        let allSongs: AllSongs = try await client.send(.get("/songs")).value
        
        let songs = allSongs.data.list.map({
            $0.convertToSong()
        })
        
        return songs
    }
    
    /// get all songs
    func getSongs() async throws -> [SongDetail] {
        let songs: [Song] = try await _getSongs()
        
        var songDetails: [SongDetail] = []
        
        await withTaskGroup(of: (SongDetail?).self) { group in
            for song in songs {
                group.addTask {
                    return try? await self.getSong(songId: song.id)
                }
            }
            
            for await songDetail in group {
                if let songDetail {
                    songDetails.append(songDetail)
                }
            }
        }
        
        return songDetails
    }
    
    /// get specific album
    func getAlbum(albumId: String) async throws -> AlbumDetail {
        let album: AlbumDetailData = try await client.send(.get("/album/\(albumId)/detail")).value
        
        return album.data
    }
    
    private func _getAlbums() async throws -> [Album] {
        let albums: AlbumsData = try await client.send(.get("/albums")).value
        
        return albums.albums
    }
    
    /// get all albums
    func getAlbums() async throws -> [AlbumDetail] {
        let albums = try await _getAlbums()
        
        var albumDetails: [Int: AlbumDetail] = [:]
        
        await withTaskGroup(of: (Int, AlbumDetail?).self) { group in
            for (index, album) in albums.enumerated() {
                group.addTask {
                    return (index, try? await self.getAlbum(albumId: album.id))
                }
            }
            
            for await (index, albumDetail) in group {
                if let albumDetail {
                    albumDetails[index] = albumDetail
                }
            }
        }
        
        return albumDetails.sorted(by: { $0.key < $1.key }).map({ $0.value })
    }
}
