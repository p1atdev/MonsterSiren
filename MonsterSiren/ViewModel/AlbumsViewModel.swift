//
//  MainViewModel.swift
//  MainViewModel
//
//  Created by 周廷叡 on 2021/11/02.
//

import Foundation

class AlbumsViewModel: ObservableObject {
    @Published var albums: [Album]?
    
    private let albumsUrl = "https://monster-siren.hypergryph.com/api/albums"
    
    func fetch(completion: @escaping (Bool) -> Void) {
        
        guard let url = URL(string: albumsUrl) else { return }
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let albumsData = data {
                    let decodedData = try JSONDecoder().decode(AlbumsData.self, from: albumsData)
                    DispatchQueue.main.async {
                        self.albums = decodedData.albums
                    }
                    
                    completion(true)
                    
                } else {
                    print("No data", data as Any)
                }
            } catch {
                print("Error", error)
            }
        }
        .resume()
        
        completion(false)
    }
}
