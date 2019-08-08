//
//  CollectionViewCell.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/7/13.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    static let cellID = "Album Cell"
    
    @IBOutlet weak var viewBehind: UIView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.black.cgColor
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
    
    func setImage(with image: UIImage?) {
        imageView.image = image
    }
    
    func setShadow(with color: CGColor) {
        viewBehind.layer.shadowColor = color
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print("called layout subview f/ album")
//        viewBehind.backgroundColor = UIColor.FilmterThemeColor.lighterBrown
//
//        let width = frame.width
//        let height = frame.height
//
//        viewBehind.frame = CGRect(x: 8, y: 8, width: width - 32, height: height - 16)
//        viewBehind.layer.shadowOpacity = 1
//        viewBehind.layer.shadowRadius = 0
//        viewBehind.layer.shadowOffset = CGSize(width: 16, height: 8)
//        viewBehind.layer.shadowColor = UIColor.FilmterThemeColor.darkBrown.cgColor
//
//        viewBehind.backgroundColor = .darkGray // very important
//        layer.masksToBounds = false
        
        
        // add corner radius on `contentView`
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 8
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("called awakefromnib subview f/ album")
        viewBehind.backgroundColor = UIColor.FilmterThemeColor.lightShadow

        
        let width = frame.width
        let height = frame.height
        
        viewBehind.frame = CGRect(x: 24, y: 8, width: width - 32, height: height - 16)
        viewBehind.layer.shadowOpacity = 1
        viewBehind.layer.shadowRadius = 0
        viewBehind.layer.shadowOffset = CGSize(width: 8, height: 8)
        viewBehind.layer.shadowColor = UIColor.FilmterThemeColor.purpleShadow.cgColor
        
        viewBehind.layer.borderWidth = 0.5
        viewBehind.layer.borderColor = UIColor.gray.cgColor


    

        // Initialization code
    }
    
    
}
