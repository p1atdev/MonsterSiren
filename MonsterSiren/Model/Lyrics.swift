//
//  Lyrics.swift
//  MonsterSiren
//
//  Created by 周廷叡 on 2021/12/16.
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
        self.lyrics = parser.lyrics
    }
    
    // 歌詞データを消す
    func clearLyrics() {
        lyrics = nil
    }
}
