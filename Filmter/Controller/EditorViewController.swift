//
//  EditorViewController.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/7/13.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//

import UIKit
import CoreImage

protocol ImageSending: NSObject {
    func takeImage(image :UIImage)
}

class EditorViewController: UIViewController {
//    @IBOutlet weak var testBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var topSubtitleTextField: UITextField!
    @IBOutlet weak var bottomSubtitleTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            if imageView.image == nil {
//                imageView.image = UIImage(named: "TEST")
                imageView.image = imageViewContainer
            }
        }
    }
    
    var imageViewContainer: UIImage?
    var editedPhoto: UIImage?
    var sentEditedPhotoBack: ((UIImage) -> ())?
    let context = CIContext()
    
    @IBOutlet weak var subTextFieldBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomSubtitleTextField.delegate = self
        bottomSubtitleTextField.backgroundColor = .none
        bottomSubtitleTextField.textColor = .white
        
        topSubtitleTextField.delegate = self
        topSubtitleTextField.backgroundColor = .none
        topSubtitleTextField.textColor = .white
        topSubtitleTextField.isHidden = true
        
//        handleKeyboard()
        
        setNavBar()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.FilmterThemeColor.dark

    }
    private func setNavBar() {
        
        let saveBtn = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(handleSave))
        let attribute = [NSAttributedString.Key.font: UIFont(name: "Baskerville-SemiBold", size: 20.0)!]
        saveBtn.setTitleTextAttributes(attribute, for: .normal)
        navigationItem.rightBarButtonItem = saveBtn
        navigationItem.backBarButtonItem?.title = ""
    }
    
    @objc func handleSave() {
        editedPhoto = backgroundView.asImage()
        sentEditedPhotoBack?(editedPhoto!)
        navigationController?.popViewController(animated: true)
    }
    
//    private func handleKeyboard() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleKeyboardWillShow),
//                                               name: UIResponder.keyboardWillShowNotification,
//                                               object: nil)
//    }
    
//    private var keyboardHeight: CGFloat = 0
//    private lazy var btmConstraint = subTextFieldBottomConstraint.constant
//
//    @objc func handleKeyboardWillShow(notification: Notification) {
//        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size
//        {
//            keyboardHeight = keyboardFrame.height
//
//            print("subTextFieldBottomConstraint.constant: ", subTextFieldBottomConstraint.constant)
//            if subTextFieldBottomConstraint.constant == btmConstraint {
//                subTextFieldBottomConstraint.constant += keyboardFrame.height
//            } else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 3, animations: {
//                    self.view.setNeedsLayout()
//                })
//            }
//
//        }
//
//    }
    
    weak var delegate: ImageSending?
    //MARK:- Filter -
    private func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage? {
        
        let ciImage = CIImage(image: image)
        
        if filterEffect.filterName.rawValue == FilterName.original.rawValue {
            return imageViewContainer
        }
        
        let filter = CIFilter(name: filterEffect.filterName.rawValue)
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let filterEffectValue = filterEffect.fileterEffectValue, let filterEffectValueName = filterEffect.filterEffectValueName {
            filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
        }
        
        var filteredImage: UIImage?
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage, let cgiImageResult = context.createCGImage(output, from: output.extent) {
            filteredImage = UIImage(cgImage: cgiImageResult)
        }
    
        return filteredImage
    }
    
    struct Filter {
        let filterName: FilterName
        var fileterEffectValue: Any?
        var filterEffectValueName: String?
        
    }
    
    enum FilterName: String {
        case original = "original"
        case sepia = "CISepiaTone"
        case mono = "CIPhotoEffectMono"
        case effectProcess = "CIPhotoEffectProcess"
        case blur = "CIGaussianBlur"
        case transfer = "CIPhotoEffectTransfer"
        case comic = "CIComicEffect"
        
        func prettyName() -> String {
            switch self {
            case .original:
                return "Original"
            case .blur:
                return "Blur"
            case .sepia:
                return "Sepia"
            case .mono:
                return "Mono"
            case .effectProcess:
                return "Photo Effect Process"
            case .transfer:
                return "Transfer"
            case .comic:
                return "Comic"
            }
        }
    }
    
    private var filters: [Filter] = [
        Filter(filterName: .original, fileterEffectValue: nil, filterEffectValueName: nil),
        Filter(filterName: .sepia, fileterEffectValue: 0.9, filterEffectValueName: kCIInputIntensityKey),
        Filter(filterName: .mono, fileterEffectValue: nil, filterEffectValueName: nil),
        Filter(filterName: .effectProcess, fileterEffectValue: nil, filterEffectValueName: nil),
        Filter(filterName: .blur, fileterEffectValue: 8, filterEffectValueName: kCIInputRadiusKey),
        Filter(filterName: .transfer, fileterEffectValue: nil, filterEffectValueName: nil),
        Filter(filterName: .comic, fileterEffectValue: nil, filterEffectValueName: nil)
    ]


}

extension EditorViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.cellID, for: indexPath) as? FilterCell
        if let image = imageView.image {
            cell?.filterImage.image = applyFilterTo(image: image, filterEffect: filters[indexPath.item])
        }
        cell?.filterLabel.text = filters[indexPath.item].filterName.prettyName()
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = imageView.image else {return}
        
        imageView.image = applyFilterTo(image: image, filterEffect: filters[indexPath.item])


    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension EditorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == topSubtitleTextField {
            bottomSubtitleTextField.isHidden = false
            bottomSubtitleTextField.text = topSubtitleTextField.text
            topSubtitleTextField.isHidden = true
        }
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == bottomSubtitleTextField {
            topSubtitleTextField.isHidden = false
            bottomSubtitleTextField.isHidden = true
            topSubtitleTextField.becomeFirstResponder()
            return false
        }
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        
//        if subTextFieldBottomConstraint.constant > btmConstraint {
//        subTextFieldBottomConstraint.constant = btmConstraint
//        }
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 3, animations: {
//                self.view.setNeedsLayout()
//            })
//        }
//
//        buttomSubtitleTextField.resignFirstResponder()
//    }
    
   
}


extension UIView {
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
