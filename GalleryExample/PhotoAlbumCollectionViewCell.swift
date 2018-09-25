//
//  PhotoAlbumCollectionViewCell.swift
//  PICMOB
//
//  Created by Mohit Singh on 8/9/18.
//  Copyright © 2018 Mohit Singh. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    
    @IBOutlet weak var albumNameLabel: UILabel!
    
    @IBOutlet weak var photoCountsLabel: UILabel!
    
    @IBOutlet weak var radioImageView: UIImageView!
    var representedAssetIdentifier: String!
}
