//
//  LyricsViewModel.swift
//  MonsterSiren
//
//  Created by p1atdev on 2021/12/16.
//

import SwiftUI


class LyricsViewModel: ObservableObject {
    @Published var lyrics: Lyrics = Lyrics()
    
    /// 歌詞を取得する
    /// 歌詞をURLから取得する
    @available(*, deprecated, message: "Use async version of fetchLyricsFrom")
    func fetchLyricsFrom(_ url: String?)  {
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
    
    /// async で歌詞をurlから取得
    func fetchLyricsFrom(_ url: String?) async {
        guard let urlString = url else { return }
        guard let url = URL(string: urlString) else { return }
        
        do {
            // リクエスト
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            self.lyrics.parseLyricsFrom(data)
            
        } catch {
            print("[*] 歌詞取得エラー:", error)
        }
    }
    
    // 歌詞を消す
    func clearLyrics() {
        self.lyrics.clearLyrics()
    }
}
