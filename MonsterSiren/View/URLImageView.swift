//
//  URLImageView.swift
//  URLImageView
//
//  Created by 周廷叡 on 2021/11/02.
//

import SwiftUI

struct URLImageView: View {
    
    @ObservedObject var viewModel: URLImageViewModel
    
    var body: some View {
        if let imageData = self.viewModel.downloadData {
            if let image = UIImage(data: imageData) {
                return Image(uiImage: image).resizable().scaledToFit()
            } else {
                return Image(uiImage: UIImage()).resizable().scaledToFit()
            }
        } else {
            return Image(uiImage: UIImage()).resizable().scaledToFit()
        }
    }
}
