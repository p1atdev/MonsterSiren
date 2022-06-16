//
//  URLImageView.swift
//  URLImageView
//
//  Created by p1atdev on 2021/11/02.
//

import SwiftUI
import NukeUI

struct URLImageView: View {
    @State var url: String
    
    var body: some View {
        
        LazyImage(source: url) { state in
            if let image = state.image {
                image // Displays the loaded image
            } else if state.error != nil {
                EmptyView()
            } else {
                // Acts as a placeholder
                Color.black
                    .opacity(0.1)
            }
        }
    }
}
