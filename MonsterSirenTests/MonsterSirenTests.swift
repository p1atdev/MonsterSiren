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
        
        let albumsModel = AlbumsViewModel()
        
        await albumsModel.fetch(completion: { _ in
            print("fin")
        })
        
        print("Albums:", albumsModel.albums)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
