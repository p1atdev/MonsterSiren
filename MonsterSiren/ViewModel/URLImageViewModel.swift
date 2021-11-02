//
//  URLImageViewModel.swift
//  URLImageViewModel
//
//  Created by p1atdev on 2021/11/02.
//

// URL: https://www.yururiwork.net/archives/759
// URL: https://qiita.com/4q_sano/items/c3c108198f7b162c5932

import SwiftUI

final class URLImageViewModel: ObservableObject {

    @Published var downloadData: Data? = nil
    let url: String

    init(url: String, isSync: Bool = false) {
        self.url = url
        if isSync {
            self.downloadImageSync(url: self.url)
        } else {
            self.downloadImageAsync(url: self.url)
        }
    }

    func downloadImageAsync(url: String) {

        guard let imageURL = URL(string: url) else {
            return
        }

        let cache = URLCache.shared
        let request = URLRequest(url: URL(string: url)!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad)
        if let data = cache.cachedResponse(for: request)?.data {
            self.downloadData = data
        }else {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                DispatchQueue.main.async {
                    self.downloadData = data
                }
            }
        }
    }

    func downloadImageSync(url: String) {

        guard let imageURL = URL(string: url) else {
            return
        }

        let cache = URLCache.shared
        let request = URLRequest(url: URL(string: url)!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad)
        if let data = cache.cachedResponse(for: request)?.data {
            self.downloadData = data
        }else {
            let data = try? Data(contentsOf: imageURL)
            self.downloadData = data
        }
    }
}
