//
//  PhotoBookNavigationBar.swift
//  Photobook
//
//  Created by Jaime Landazuri on 09/11/2017.
//  Copyright © 2017 Kite.ly. All rights reserved.
//

import UIKit

class PhotoBookNavigationBar: UINavigationBar {
    
    var hasAddedWhiteUnderlay = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        barTintColor = .white
        if #available(iOS 11.0, *) {
            prefersLargeTitles = true
        }
        shadowImage = UIImage()
    }
    
}
