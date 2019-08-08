//
//  PhotoCell.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/7/31.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    static let cellID = "Photo Cell"
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.borderWidth = 0.87
            imageView.layer.borderColor = UIColor.darkGray.cgColor
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
        

        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black
        // Initialization code
    }
    
}
