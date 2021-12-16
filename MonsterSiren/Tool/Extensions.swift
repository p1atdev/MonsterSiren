//
//  Extensions.swift
//  Extensions
//
//  Created by p1atdev on 2021/11/03.
//

import UIKit
import SwiftUI

extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}

extension String
{
    func sizeUsingFont(fontSize: CGFloat, weight: Font.Weight) -> CGSize
    {
        var uiFontWeight = UIFont.Weight.regular
        
        switch weight {
        case Font.Weight.heavy:
            uiFontWeight = UIFont.Weight.heavy
        case Font.Weight.bold:
            uiFontWeight = UIFont.Weight.bold
        case Font.Weight.light:
            uiFontWeight = UIFont.Weight.light
        case Font.Weight.medium:
            uiFontWeight = UIFont.Weight.medium
        case Font.Weight.semibold:
            uiFontWeight = UIFont.Weight.semibold
        case Font.Weight.thin:
            uiFontWeight = UIFont.Weight.thin
        case Font.Weight.ultraLight:
            uiFontWeight = UIFont.Weight.ultraLight
        case Font.Weight.black:
            uiFontWeight = UIFont.Weight.black
        default:
            uiFontWeight = UIFont.Weight.regular
        }
        
        let font = UIFont.systemFont(ofSize: fontSize, weight: uiFontWeight)
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

extension NSURLRequest {
    static func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
        return true
    }
}

extension View {
    
    /// 現在のセーフエリアの幅を返すよ
    var safeAreaIntents: UIEdgeInsets {
        let keyWindow = UIApplication.shared.connectedScenes
        
            .filter({$0.activationState == .foregroundActive})
        
            .map({$0 as? UIWindowScene})
        
            .compactMap({$0})
        
            .first?.windows
        
            .filter({$0.isKeyWindow}).first
        
        return (keyWindow?.safeAreaInsets) ?? .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension UIImage {
    /// Average color of the image, nil if it cannot be found
    var averageColor: UIColor? {
        // convert our image to a Core Image Image
        guard let inputImage = CIImage(image: self) else { return nil }

        // Create an extent vector (a frame with width and height of our current input image)
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        // create a CIAreaAverage filter, this will allow us to pull the average color from the image later on
        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        // A bitmap consisting of (r, g, b, a) value
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        // Render our output image into a 1 by 1 image supplying it our bitmap to update the values of (i.e the rgba of the 1 by 1 image will fill out bitmap array
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        // Convert our bitmap images of r, g, b, a to a UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}

extension CharacterSet {
    public static var quotes = CharacterSet(charactersIn: "\"'")
}

extension String {
    public func emptyToNil() -> String? {
        return self == "" ? nil : self
    }
    
    public func blankToNil() -> String? {
        return self.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : self
    }
}
