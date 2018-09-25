//
//  PhotosCollectionViewCell.swift
//  PICMOB
//
//  Created by Mohit Singh on 8/9/18.
//  Copyright © 2018 Mohit Singh. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    
    @IBOutlet weak var selectImageView: UIImageView!
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            albumImage.image = thumbnailImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumImage.image = nil
    }
    
}
