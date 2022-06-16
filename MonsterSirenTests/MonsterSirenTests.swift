//
//  MonsterSirenTests.swift
//  MonsterSirenTests
//
//  Created by p1atdev on 2021/11/02.
//

import XCTest
@testable import MonsterSiren

class MonsterSirenTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        
        
    }
    
    func testGetSongs() async throws {
        let client = MonsterSirenClient()
        
        let songs = try await client.getSongs()
        
        assert(songs.count != 0, "failed to get songs")
        
        let album = try await client.getAlbum(albumId: "0256")
        
        assert(album.name == "Your Star", "failed to get album")
        
        assert(album.songs.count != 0, "album has no songs")
        
        let song = try await client.getSong(songId: album.songs.first!.id)

        assert(song.id == "306846", "song is wrong")
    }
    
    func testGetAlbums() async throws {
        let client = MonsterSirenClient()
        
        let albums = try await client.getAlbums()
        
        print(albums)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
