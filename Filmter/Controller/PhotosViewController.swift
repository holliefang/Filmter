//
//  PhotosViewController.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/7/13.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var images = [NSData]()
    
//    private func setupCollectionView() {
//        let nib = UINib(nibName: "AlbumCell", bundle: nil)
//        self.collectionView.register(nib, forCellWithReuseIdentifier: AlbumCell.cellID)
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupCollectionView()
        pageControl.numberOfPages = images.count
        

        
    }
    
    @IBAction func handlePrevious(_ sender: UIButton) {
        let nextIndex = max(pageControl.currentPage - 1, 0)
        pageControl.currentPage = nextIndex
        let indexPath = IndexPath(item: nextIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    
        
        
        
    }
    @IBAction func handleNext(_ sender: UIButton) {
        let nextPage = min(pageControl.currentPage + 1, images.count - 1)
        
        let indexPath = IndexPath(item: nextPage, section: 0)
        pageControl.currentPage = nextPage
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(x / view.frame.width)
    }
    
    //MARK:- CollectionView Setting
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SwipeCell.cellID, for: indexPath) as? SwipeCell else {
            return UICollectionViewCell()
        }
        
        if let data = images[indexPath.item] as Data? {
            cell.imageView.image = UIImage(data: data)
            cell.imageView.contentMode = .scaleAspectFit
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width,
                      height: view.frame.height - previousBtn.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

}
