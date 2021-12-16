//
//  LyricsViewModel.swift
//  MonsterSiren
//
//  Created by 周廷叡 on 2021/12/16.
//

import SwiftUI


class LyricsViewModel: ObservableObject {
    @Published var lyrics: Lyrics = Lyrics()
    
    // 歌詞を取得する
    // 歌詞をURLから取得する
    func fetchLyricsFrom(_ url: String?) {
        guard let url = url else { return }
        // テキストデータが欲しい
        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: URL(string: url)!) { (data, res, err) in
                // エラーなら終了
                if let err = err {
                    print(err)
                    return
                }
                
                // パース
                self.lyrics.parseLyricsFrom(data)
            }
            .resume()
        }
    }
    
    // 歌詞を消す
    func clearLyrics() {
        self.lyrics.clearLyrics()
    }
}
