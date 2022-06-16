//
//  MainViewModel.swift
//  MainViewModel
//
//  Created by p1atdev on 2021/11/02.
//

import Foundation

class AlbumsViewModel: ObservableObject {
    @Published var albums: [AlbumDetail]?
    
    let client = MonsterSirenClient()

    /// アルバムを取得
    func fetch() async -> Bool {
        do {
            let albums = try await client.getAlbums()
            DispatchQueue.main.async {
                self.albums = albums
            }
            return true
        } catch {
            return false
        }
    }
}
