//
//  FilterCell.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/7/31.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    static let cellID = "Filter Cell"
    @IBOutlet weak var filterImage: UIImageView!
    @IBOutlet weak var filterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filterImage.isUserInteractionEnabled = true
        filterImage.layer.masksToBounds = true
//        filterImage.clipsToBounds = true
        filterLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        filterLabel.layer.cornerRadius = 20
        filterLabel.clipsToBounds = true
        
        filterLabel.backgroundColor = UIColor.FilmterThemeColor.modest
        filterImage.layer.cornerRadius = 20


    }

    
}
