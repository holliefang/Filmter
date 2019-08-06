//
//  CollectionViewCell.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/7/13.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    static let cellID = "Photo Cell"
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
//            imageView.layer.shadowColor = UIColor.red.cgColor
//            imageView.layer.masksToBounds = false
//            imageView.layer.shadowOffset = CGSize(width: 1, height: -1)
//            imageView.layer.shadowRadius = 3
//            imageView.layer.opacity = 1
//            imageView.layer.shadowPath = UIBezierPath(rect: imageView.layer.bounds).cgPath
//            imageView.layer.shouldRasterize = true
//            imageView.layer.borderColor = UIColor.red.cgColor
        }
    }
    @IBOutlet weak var selectionImage: UIImageView!
    
    var isEditing: Bool = false {
        didSet {
            selectionImage.isHidden = isEditing ? false : true
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isEditing {
                let image = isSelected ? UIImage(named: "Checked") : UIImage(named: "Unchecked")
                selectionImage.image = image
            }
        }
    }
    
    func setOutlet(image: UIImage?) {
        imageView.image = image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print("called layout subview")
        
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowColor = UIColor.white.cgColor
        
        // add corner radius on `contentView`
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}
