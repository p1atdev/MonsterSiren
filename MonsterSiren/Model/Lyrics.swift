//
//  Lyrics.swift
//  MonsterSiren
//
//  Created by p1atdev on 2021/12/16.
//

import SwiftUI

// 歌詞
class Lyrics {
    // 時間と該当する歌詞
    var lyrics: [LyricsItem]? = nil
    
    // 歌詞をデータから取得
    func parseLyricsFrom(_ data: Data?) {
        guard let lyricsData = data else {
            self.lyrics = nil
            return
        }
        
        // LRCのテキストデータ
        guard let lyricsString = String(data: lyricsData, encoding: .utf8) else {
            self.lyrics = nil
            return
        }
        
        let parser = LyricsParser(lyrics: lyricsString)
        // 時間が早いか、同じ時間であれば文字が早い方(英字)を先にする
        self.lyrics = parser.lyrics.sorted(by: { $0.time < $0.time && $0.text < $1.text })
    }
    
    // 歌詞データを消す
    func clearLyrics() {
        lyrics = nil
    }
}
