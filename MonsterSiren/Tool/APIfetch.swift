//
//  APIfetch.swift
//  APIfetch
//
//  Created by p1atdev on 2021/11/02.
//

import Foundation

func apiFetch<T: Decodable>(_ url: String, completion: @escaping ([T]) -> Void) {
    guard let url = URL(string: url) else { return }

    URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data else { return }
        let decoder: JSONDecoder = JSONDecoder()
        do {
            let resData = try decoder.decode([T].self, from: data)
            print(resData)
            DispatchQueue.main.async {
                completion(resData)
            }
        } catch {
            fatalError("Couldn't load \(url) :\n\(error)")
        }
    }.resume()
}
