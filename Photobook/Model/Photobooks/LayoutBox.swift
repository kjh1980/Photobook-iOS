//
//  Modified MIT License
//
//  Copyright (c) 2010-2018 Kite Tech Ltd. https://www.kite.ly
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The software MAY ONLY be used with the Kite Tech Ltd platform and MAY NOT be modified
//  to be used with any competitor platforms. This means the software MAY NOT be modified
//  to place orders with any competitors to Kite Tech Ltd, all orders MUST go through the
//  Kite Tech Ltd platform servers.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

// A bounding box for an image or text
struct LayoutBox: Codable {
    
    let id: Int!
    // Normalised rect
    let rect: CGRect!
    
    func isLandscape() -> Bool { return rect.width > rect.height }
    
    func isSquareEnoughForVoiceOver() -> Bool {
        let ratio = rect.width / rect.height
        return ratio > 0.85 && ratio < 1.15
    }
    
    func rectContained(in pageSize: CGSize) -> CGRect {
        let x = rect.minX * pageSize.width
        let y = rect.minY * pageSize.height
        let width = rect.width * pageSize.width
        let height = rect.height * pageSize.height
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func bleedRect(in containerSize: CGSize, withBleed bleed: CGFloat?) -> CGRect {
        guard let bleed = bleed else {
            return CGRect(x: 0.0, y: 0.0, width: containerSize.width, height: containerSize.height)
        }
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var width: CGFloat = containerSize.width
        var height: CGFloat = containerSize.height
        
        if rect.minX ~= 0.0 { // Left bleed
            x = -bleed
            width += bleed
        }
        if rect.maxX ~= 1.0 { // Right bleed
            width += bleed
        }
        if rect.minY ~= 0.0 { // Top bleed
            y = -bleed
            height += bleed
        }
        if rect.maxY ~= 1.0 { // Bottom bleed
            height += bleed
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func aspectRatio(forContainerRatio ratio: CGFloat) -> CGFloat {
        let containerWidth: CGFloat = 1000.0
        let containerHeight = containerWidth / ratio
        
        let width = containerWidth * rect.width
        let height = containerHeight * rect.height
        return width / height
    }
    
    func containerSize(for size: CGSize) -> CGSize {
        let width = size.width / rect.width
        let height = size.height / rect.height
        return CGSize(width: width, height: height)
    }
        
    static func parse(_ layoutBoxDictionary: [String: AnyObject]) -> LayoutBox? {
        guard
            let id = layoutBoxDictionary["id"] as? Int,
            let rectDictionary = layoutBoxDictionary["rect"] as? [String: AnyObject],
            let x = rectDictionary["x"] as? Double, x.isNormalised,
            let y = rectDictionary["y"] as? Double, y.isNormalised,
            let width = rectDictionary["width"] as? Double, width.isNormalised,
            let height = rectDictionary["height"] as? Double, height.isNormalised
            else { return nil }
        
        return LayoutBox(id: id, rect: CGRect(x: x, y: y, width: width, height: height))
    }
}
