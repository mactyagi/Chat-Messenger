//
//  extensions.swift
//  Chat Messenger
//
//  Created by manukant tyagi on 13/06/22.
//

import Foundation
import UIKit


extension UIImage{
    var isPortrait: Bool {
        return size.height > size.width
    }
    var isLandscape: Bool {
        return size.height < size.width
    }
    var breadth: CGFloat {
        return min(size.height, size.width)
    }
    
    var breadthSize: CGSize{
        return CGSize(width: breadth, height: breadth)
    }
    var breadthRect: CGRect{
        return CGRect(origin: .zero, size: breadthSize)
    }
    
    var circleMasked: UIImage?{
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else {
            return nil
        }
        
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
