//
//  URLDynamicImageView.swift
//  MonsterSiren
//
//  Created by p1atdev on 2021/11/03.
//

import SwiftUI
import NukeUI

struct URLDynamicImageView: View {
    
    @Binding var url: String
    
    var body: some View {
        LazyImage(source: url) { state in
            if let image = state.image {
                image // Displays the loaded image
            } else if state.error != nil {
                EmptyView()
            } else {
                Color.black
                    .opacity(0.1)
            }
        }
    }
}
