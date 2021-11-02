//
//  MainView.swift
//  MainView
//
//  Created by p1atdev on 2021/11/02.
//

// アルバム一覧を取得して表示する画面

import SwiftUI

struct AlbumsView: View {
    /// アルバムのデータ
    @StateObject var albumsModel = AlbumsViewModel()
    /// アルバムが読み込まれたかどうか
    @Binding var loaded: Bool
    
    /// 遷移するアルバム
    @State var albumToPresent: Album?
    
    /// プレーヤーのやつ
    @ObservedObject var playerViewModel: PlayerViewModel
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    /// アルバムの列の数
    let columns: [GridItem] = [GridItem(.adaptive(minimum: 200, maximum: 300))]
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(albumsModel.albums ?? [], id: \.id) { album in
                        Button(action: {
                            withAnimation {
                                albumToPresent = album
                            }
                        }, label: {
                            URLImageView(viewModel: .init(url: album.coverUrl))
                                .aspectRatio(1, contentMode: .fit)
                        })
                    }
                }
                .padding()
                .padding(.top, 30)
            }
            .opacity(albumToPresent == nil ? 1.0 : 0.0)
            .onAppear {
                DispatchQueue.global().async {
                    albumsModel.fetch() { status in
                        withAnimation(.linear(duration: 0.3).delay(0.5)) {
                            loaded = status
                        }
                    }
                }
            }
            
            if albumToPresent != nil {
                AlbumDetailView(album: $albumToPresent,
                                loaded: $loaded,
                                playerViewModel: playerViewModel)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}
