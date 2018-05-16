//
//  ImageCell.swift
//  Senfonico
//
//  Created by Emre HAVAN on 24.04.2018.
//  Copyright © 2018 Emre HAVAN. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
