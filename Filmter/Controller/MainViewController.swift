//
//  MainViewController.swift
//  Filmter
//
//  Created by Sihan Fang on 2019/7/13.
//  Copyright © 2019 Sihan Fang. All rights reserved.
//

import UIKit
import Photos

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var importPhotoToEditButton: UIButton!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var addToAlbumBtn: UIBarButtonItem!
    
    
    private var longPressGesture = UILongPressGestureRecognizer()
    private var tapGesture = UITapGestureRecognizer()
    
//    var savedImages = [UIImage]()
    var savedPhoto = [Photo]()
    
    var selectedPictureFromPicker: UIImage?
//    var albums = [[UIImage]]()
    var savedAlbums = [Album]()
    
    private var cellCenterX: CGFloat = 0
    private var cellCenterY: CGFloat = 0
    
    lazy var zoomView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var buttons: [UIBarButtonItem]?
    private var shareImage: UIImage?
    
    //MARK:- TEST Property -
    lazy var imageArray = [testImage, testImage, testImage, testImage, testImage, testImage, testImage, testImage, testImage]
    var testImage = UIImage(named: "TEST")
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        buttons = [deleteBtn, addToAlbumBtn]
        
        setupCollectionView(for: photoCollectionView)
        setupCollectionView(for: albumCollectionView)
        setupNavItemAndOutlet()
        
        longPressGesture.addTarget(self, action: #selector(handleLongPress(for:)))
        tapGesture.addTarget(self, action: #selector(tapGesture(for:)))
        photoCollectionView.addGestureRecognizer(longPressGesture)
        zoomView.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        appDelegate.deleteData()
        
        do {
            savedPhoto = try context.fetch(Photo.fetchRequest())
            savedAlbums = try context.fetch(Album.fetchRequest())
        } catch {
            let error = error as NSError
            print("got an error here")
            print(error, error.userInfo)
        }
        
        toggleEditBtn()
    }
    
    //MARK:- Gestures Setup -
    @objc func handleLongPress(for longPressGesture: UILongPressGestureRecognizer) {
        switch longPressGesture.state {
        case .began:
            guard let selectedIndexPath = photoCollectionView.indexPathForItem(at: longPressGesture.location(in: photoCollectionView)) else {return}
            photoCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            photoCollectionView.updateInteractiveMovementTargetPosition(longPressGesture.location(in: longPressGesture.view))
        case .ended:
            photoCollectionView.endInteractiveMovement()
        default:
            photoCollectionView.cancelInteractiveMovement()
        }
    }
    
    @objc func tapGesture(for tapGesture: UITapGestureRecognizer) {
        switch tapGesture.state {
        case .ended:
            UIView.animate(withDuration: 0.3, animations: {
                self.zoomView.frame = CGRect(x: self.cellCenterX, y: self.cellCenterY, width: 0, height: 0)
                
            }) {  [unowned self] (_) in
                
                self.zoomView.removeFromSuperview()
            }
            //FIXME:- NAV ITEM OUTLETS SETUP -
            navigationItem.leftBarButtonItem = editButtonItem
            navigationItem.title = "Filmter"
            navigationItem.rightBarButtonItem = nil
            navigationItem.rightBarButtonItems = buttons
            
        default:
            break
        }
    }
    
    //MARK:- Outlets Setup -
    private func setupNavItemAndOutlet() {
        navigationItem.leftBarButtonItem = editButtonItem
        importPhotoToEditButton.backgroundColor = UIColor.FilmterThemeColor.dark
        importPhotoToEditButton.tintColor = UIColor.FilmterThemeColor.light
        
        
        
        toggleEditBtn()
    }
    private func setupCollectionView(for collection: UICollectionView) {
        collection.delegate = self
        collection.dataSource = self
        
        photoCollectionView.backgroundColor = UIColor.FilmterThemeColor.modest
        albumCollectionView.backgroundColor = UIColor.FilmterThemeColor.light

        albumCollectionView.register(UINib(nibName: "AlbumCell", bundle: nil), forCellWithReuseIdentifier: AlbumCell.cellID)
    }
    
    // MARK:- Editing CollectionView -
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        setEditing(for: photoCollectionView, when: editing)
        setEditing(for: albumCollectionView, when: editing)
        
        addToAlbumBtn.isEnabled = false
        deleteBtn.isEnabled = false
        toggleEditBtn()
    }
    
    private func setEditing(for collectionView: UICollectionView, when editing: Bool) {
        collectionView.allowsMultipleSelection = editing
        collectionView.indexPathsForSelectedItems?.forEach{
            collectionView.deselectItem(at: $0, animated: false)
        }
        let indexPaths = collectionView.indexPathsForVisibleItems
        
        if collectionView == photoCollectionView {
            for indexPath in indexPaths {
                let photoCell = collectionView.cellForItem(at: indexPath) as! PhotoCell
                photoCell.isEditing = editing
            }
        } else if collectionView == albumCollectionView {
            for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! AlbumCell
            cell.isEditing = editing
            }
        }
        
        



    }
    
    @IBAction func handleDelete() {
        
        guard let selected = photoCollectionView.indexPathsForSelectedItems else {return}
        let items = selected.map{$0.item}.sorted().reversed()
        for item in items {
            let photo = savedPhoto[item]
            savedPhoto.remove(at: item)
            context.delete(photo)
            
        }
        photoCollectionView.deleteItems(at: selected)
        appDelegate.saveContext()
        
        guard let savedPhotoSelected = albumCollectionView.indexPathsForSelectedItems else {return}
        let savedItems = savedPhotoSelected.map{$0.item}.sorted().reversed()
        for savedItem in savedItems {
            let album = savedAlbums[savedItem]
            savedAlbums.remove(at: savedItem)
            context.delete(album)
        }
        albumCollectionView.deleteItems(at: savedPhotoSelected)

        isEditing = !isEditing
        appDelegate.saveContext()
    }
    
    
    
    @IBAction func handleAddToPhotos() {
        let album = Album(entity: Album.entity(), insertInto: context)

        var photoDatas = [NSData]()
        
        guard let selected = photoCollectionView.indexPathsForSelectedItems?.sorted() else {return}
        for selection in selected {

            if let phtoData = savedPhoto[selection.item].image {
                photoDatas.append(phtoData)
            }
            
//            album.addToPhotos(savedPhoto[selection.item])
        }
        
        album.photos = photoDatas
        
        savedAlbums.append(album)
        appDelegate.saveContext()
        
        isEditing = !isEditing
        albumCollectionView.reloadData()
        
    }
    private func toggleEditBtn() {
        if savedPhoto.count > 0 {
            editButtonItem.isEnabled = true
        } else if savedAlbums.count > 0 {
            editButtonItem.isEnabled = true
        } else {
            editButtonItem.isEnabled = false
        }
    }

    //MARK:- UIImagePickerController Methods -
    @IBAction @objc func importFromPhotoToEdit(_ sender: UIButton) {
            checkPermission()
        if isEditing {
            isEditing = !isEditing
        }

    }
    
    
    lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            selectedPictureFromPicker = image
        } else if let image = info[.originalImage] as? UIImage {
            selectedPictureFromPicker = image
        }
        self.dismiss(animated: true, completion: {[unowned self] in
        self.performSegue(withIdentifier: "Show Editor", sender: nil)
        })
        
    }
    
    private func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            self.show(picker, sender: nil)
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({(newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    self.show(self.picker, sender: nil)
                    print("success")}})
            print("It is not determined until now")
        case .restricted:
            let alert = UIAlertController(title: "Photo Library Restricted",
                                          message: "Photo Library is restricted and cannnot be accessed",
                                          preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(OKAction)
            self.present(alert, animated: true)

            print("User do not have access to photo album.")
        case .denied:
            let alert = UIAlertController(title: "Photo Library Denied",
                                          message: "Photo Library was previously denied. Please update your Settings.",
                                          preferredStyle: .alert)
            let goToSettingAction = UIAlertAction(title: "Go to settings", style: .default) { (action) in
                DispatchQueue.main.async {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(goToSettingAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)

            print("User has denied the permission.")
        @unknown default:
            fatalError()
        }
    }



    
    // MARK:- Segue -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Show Editor" {
                guard let editorVC = segue.destination as? EditorViewController else {return}
                if let importPhoto = selectedPictureFromPicker {
                        editorVC.imageViewContainer = importPhoto
                    
                }
                editorVC.sentEditedPhotoBack = {[unowned self] pic in
                    print("clousure sent successfully")
                    let photo = Photo(entity: Photo.entity(), insertInto: self.context)
                    photo.image = pic.pngData() as NSData?
                    self.savedPhoto.append(photo)
                    self.appDelegate.saveContext()
                    
                    self.photoCollectionView.reloadData()
                }
            } else if identifier == "Show Photos" {
                guard let senderIndex = sender as? IndexPath else {return}
                print(senderIndex)
                if let photosVC = segue.destination as? PhotosViewController  {
                    print("Sent images to photos")
                    
                    if let photos = savedAlbums[senderIndex.item].photos {
                        photosVC.images = photos
                    }
                }

            }
        }
    }
    //MARK:- CollectionView Size Reference -
    private struct PhotoSize {
        static let topEdge: CGFloat = 16
        static let leftEdge: CGFloat = 20
        static let rightEdge: CGFloat = 20
        static let bottomEdge: CGFloat = 16
        static let minLineSpacing: CGFloat = 16
        static let minInteritemSpacing: CGFloat = 16
    }
    
    private struct AlbumSize {
        static let topEdge: CGFloat = 34
        static let leftEdge: CGFloat = 0
        static let rightEdge: CGFloat = 10
        static let bottomEdge: CGFloat = 34
        static let minLineSpacing: CGFloat = 8
        static let minInteritemSpacing: CGFloat = 10
    }
    
    //MARK:- UIActivity Controller -
    @objc func share(from gesture: UITapGestureRecognizer) {
    
        guard let shareImage = shareImage else {return}
        let activityController = UIActivityViewController(activityItems: ["Check this out", shareImage], applicationActivities: nil)
        self.present(activityController, animated: true)
        
        
    }
    
    private func zoomView(at indexPath: IndexPath, in collectionView: UICollectionView) {
        shareImage = nil
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        
        let cell = collectionView.cellForItem(at: indexPath)
        let paddingX = (cell?.frame.width)! / 2
        let paddingY = (cell?.frame.height)! / 2
        let origin = collectionView.convert((cell?.frame.origin)!, to: collectionView.superview!)
        cellCenterX = origin.x + paddingX
        cellCenterY = origin.y + paddingY
        
        zoomView.frame = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
        
        self.view.addSubview(zoomView)
        UIView.animate(withDuration: 0.2) {
            
            let width = UIWindow().screen.bounds.width
            let height = UIWindow().screen.bounds.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            self.zoomView.frame = frame
            self.zoomView.alpha = 1
            
            let data = self.savedPhoto[indexPath.item].image as Data?
            self.shareImage = UIImage(data: data!)
            
            self.zoomView.image = self.shareImage
        }
    }
    
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    //MARK:- CollectionView Layout -
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(view.frame)
        
//        let totalItemPerRow: CGFloat = 3
//        let totalSpacing = (2 * PhotoSize.leftEdge) + (PhotoSize.minLineSpacing * (totalItemPerRow - 1))
//
//
        if collectionView == photoCollectionView {
//            let width = (photoCollectionView.bounds.width - totalSpacing) / totalItemPerRow
//            let height = (photoCollectionView.bounds.height - totalSpacing) / totalItemPerRow
//            print(height, "when the minLineSpacing is \(PhotoSize.minLineSpacing)")
//            print(width, "wtf")
//            return CGSize(width: width,
//                          height: height)
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height
            
            if height < width {
                return CGSize(width: width / 3, height: width / 3 * 1.2)
            } else {
                return CGSize(width: width / 3, height: width / 3 * 1.6)
            }
            
//            print("wwwwwwwwwwwww \(collectionView.bounds.width)")
//            print("hhhhhhhhhhhhh \(collectionView.bounds.height)")
//            return CGSize(width: width, height: height)
        
        
        
        } else {
            
            let width: CGFloat = (view.frame.width / 2.5) - AlbumSize.leftEdge
            let height: CGFloat = albumCollectionView.frame.height - (AlbumSize.topEdge * 2)
            
            return CGSize(width: width, height: height)
        }
            }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == photoCollectionView {
            
            return UIEdgeInsets.zero

//            return UIEdgeInsets(top: PhotoSize.topEdge,
//                                left: PhotoSize.leftEdge,
//                                bottom: PhotoSize.bottomEdge,
//                                right: PhotoSize.rightEdge)
        }
        return UIEdgeInsets(top: AlbumSize.topEdge,
                            left: AlbumSize.leftEdge,
                            bottom: AlbumSize.bottomEdge,
                            right: AlbumSize.rightEdge)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        switch collectionView {
        case photoCollectionView:
//            return PhotoSize.minLineSpacing
            return 0
        case albumCollectionView:
            return AlbumSize.minLineSpacing
        default:
            return 0
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        switch collectionView {
        case photoCollectionView:
            return 0
//            return PhotoSize.minInteritemSpacing
        case albumCollectionView:
            return AlbumSize.minInteritemSpacing
        default:
            return 0
        }
    }
    
    //MARK:- CollectionView Data Source -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView {
        return savedPhoto.count
        }
        return savedAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == photoCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.cellID, for: indexPath) as? PhotoCell {
                
                guard savedPhoto.count > 0 else {
                    let image = imageArray[indexPath.item]
                    cell.setOutlet(image: image)
                    return cell }
                
                let photo = savedPhoto[indexPath.item]
                if let data = photo.image as Data? {
                    cell.setOutlet(image: UIImage(data: data))
                }
                cell.isEditing = isEditing
                
                return cell
            }
            
        } else if collectionView == albumCollectionView {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.cellID, for: indexPath) as? AlbumCell {
            guard savedAlbums.count > 0 else{
                let image = imageArray[indexPath.item]
                cell.setImage(with: image)
                return cell
            }
            
            if let photoData = savedAlbums[indexPath.item].photos?.first as Data? {
                let image = UIImage(data: photoData)
                cell.setImage(with: image)
            }
            
            
            let shadowColorOffset = indexPath.item % 3
            var shadowColor = UIColor.FilmterThemeColor.purpleShadow.cgColor
            
            switch shadowColorOffset {
            case 0:
                shadowColor = UIColor.FilmterThemeColor.brownShadow.cgColor
            case 1:
                shadowColor = UIColor.FilmterThemeColor.blueShadow.cgColor
            case 2:
                shadowColor = UIColor.FilmterThemeColor.purpleShadow.cgColor
            default:
                break
            }
            
            cell.setShadow(with: shadowColor)
            
            return cell
        }
        }
        return UICollectionViewCell()
    }
    //MARK:- CollectionView Delegate -
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        toggleButton(in: photoCollectionView, button: addToAlbumBtn)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoCollectionView {
            toggleButton(in: photoCollectionView, button: addToAlbumBtn)
            
            if !isEditing {
             zoomView(at: indexPath, in: photoCollectionView)
            }
        } else if collectionView == albumCollectionView {
                if isEditing {
                    toggleButton(in: albumCollectionView)
                } else {
                    performSegue(withIdentifier: "Show Photos", sender: indexPath)
                }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard savedPhoto.count > 0 else {
            return
        }
        let image = savedPhoto.remove(at: sourceIndexPath.item)
        savedPhoto.insert(image, at: destinationIndexPath.item)
    }
    
    private func toggleButton(in collectionview: UICollectionView, button: UIBarButtonItem? = nil) {
        let selecedNumberOfCollectionView = collectionview.indexPathsForSelectedItems
        if isEditing {
            if button != nil {
                if let count = selecedNumberOfCollectionView?.count {
                    button!.isEnabled = count > 1 ? true : false
                }
            }
            deleteBtn.isEnabled = selecedNumberOfCollectionView?.count == 0 ? false : true
        } else {
            addToAlbumBtn.isEnabled = false
            deleteBtn.isEnabled = false
        }
    }
    
}

