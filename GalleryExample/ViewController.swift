//
//  ViewController.swift
//  GalleryExample
//
//  Created by KrishMac on 9/20/18.
//  Copyright © 2018 KrishMac. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
        @IBOutlet weak var collectionView: UICollectionView!

    var thumbnail_url  = [String]()
    
    
    // MARK: Properties
    
    var userCollections: PHFetchResult<PHCollection>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    let sectionLocalizedTitles = [NSLocalizedString("Albums", comment: ""), NSLocalizedString("Smart Albums", comment: "")]
    
    fileprivate let imageManager = PHCachingImageManager()
    var userCount = [Int]()
    var smartCount = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                print("Found \(allPhotos.count) assets")
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                // Should not see this when requesting
                print("Not determined yet")
            }
        }
        
        let smartOption = PHFetchOptions()
         userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: smartOption)
        PHPhotoLibrary.shared().register(self)
        
        fatchOptionsForAlbums()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        URLCache.shared.removeAllCachedResponses()
    }
    
    
//    private func setupPhotos() {
//        let fetchOptions = PHFetchOptions()
//
//        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
//
//        let topLevelfetchOptions = PHFetchOptions()
//
//        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: topLevelfetchOptions)
//
//        let allAlbums = [topLevelUserCollections, smartAlbums]
//
//        for i in 0 ..< allAlbums.count {
//            let result = allAlbums[i]
//
//            topLevelUserCollections.enumerateObjects { (asset, index, stop) -> Void in
//                if let a = asset as? PHAssetCollection {
//                    let opts = PHFetchOptions()
//
//                    if #available(iOS 9.0, *) {
//                        opts.fetchLimit = 1
//                    }
//
//                    let ass = PHAsset.fetchAssets(in: a, options: opts)
//                    if let _ = ass.firstObject {
//                        let obj = MYSpecialAssetContainerStruct(asset: a)
//                        self.data.append(obj)
//                    }
//                }
//
//                if i == (allAlbums.count - 1) && index == (result.count - 1) {
//                    self.data.sortInPlace({ (a, b) -> Bool in
//                        return a.asset.localizedTitle < b.asset.localizedTitle
//                    })
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
    
    func fatchOptionsForAlbums() {
        
         let fetchOptions = PHFetchOptions()
        for i in 0..<userCollections.count {
            
            let collection = userCollections.object(at: i)
            
           
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            
            let result1 = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: fetchOptions)
            
            print("pppp\(result1.count)")
            
            userCount.append(result1.count)
        
        
        }
        
        for i in 0..<smartAlbums.count {
            
            let collection = smartAlbums.object(at: i)
            
          //  let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            
            let result1 = PHAsset.fetchAssets(in: collection , options: fetchOptions)
            
            print("pppp\(result1.count)")
            smartCount.append(result1.count)
        }
        
        
        getAllImagesFromSection1()
        
    }
    var imageArrayForSection1 = [UIImage]()
 
    
    func getAllImagesFromSection1() {
        DispatchQueue.global(qos: .background).async {
            for i in 0..<self.userCollections.count {
                let collection = self.userCollections.object(at: i)
                let  fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                
                let result1 = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: fetchOptions)
                
                // imageArray.removeAll()
                for i in 0..<result1.count{
                    
                    let asset = result1.object(at: i)
                    let representedAssetIdentifier = asset.localIdentifier
                    // let imageSize = CGSize(width: asset.pixelWidth,height: asset.pixelHeight)
                    let imageSize = CGSize(width: asset.pixelWidth/2, height: asset.pixelHeight/2)
                    self.imageManager.requestImage(for:asset , targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                        // The cell may have been recycled by the time this handler gets called;
                        // set the cell's thumbnail image only if it's still showing the same asset.
                        if image != nil {
                            print("imaaaag\(image!)")
                            if representedAssetIdentifier == asset.localIdentifier {
                                if i == 0 {
                                self.imageArrayForSection1.append(image!)
                                }
                            }
                        }
                    })
                    
                }
            }
            
//            DispatchQueue.main.async {
//                 self.collectionView.reloadData()
//            }
            self.getAllImagesFromSection2()
        }
    
    }
    
       var imageArrayForSection2 = [UIImage]()
    
    //for second section
    func getAllImagesFromSection2() {
        DispatchQueue.global(qos: .background).async {
            
            for i in 0..<self.smartAlbums.count {
                let collection = self.smartAlbums.object(at: i)
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                
                let result1 = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                print("estimate count \(result1.count)")
                
                
                
                //  print("imaaaag\(result1)")
                
                //            var imageArray = [UIImage]()
                //imageArray.removeAll()
                for i in 0..<result1.count{
                    if i == 0 {
                        let asset = result1.object(at: i)
                        let representedAssetIdentifier = asset.localIdentifier
                        
                        let imageSize = CGSize(width: asset.pixelWidth,
                                               height: asset.pixelHeight)
                        self.imageManager.requestImage(for:asset , targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                            // The cell may have been recycled by the time this handler gets called;
                            // set the cell's thumbnail image only if it's still showing the same asset.
                            if image != nil {
                                print("secondimagggeesss\(image!)")
                                if representedAssetIdentifier == asset.localIdentifier {
                                    
                                    self.imageArrayForSection2.append(image!)
                                    
                                    
                                }
                            }
                            
                        })
                        
                    }
                }
                
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
    }


}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
    
            return 2
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return self.userCollections.count
        } else {
            return self.smartAlbums.count
        }
        


        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoAlbumCollectionViewCell
            cell.photoCountsLabel.text = ""
            cell.albumNameLabel.text = ""
            let collection = userCollections.object(at: indexPath.row)
            cell.albumNameLabel.text = collection.localizedTitle
            
            cell.albumImage.alpha = 1
//
//                let fetchOptions = PHFetchOptions()
//                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//
//                let result1 = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: fetchOptions)
//                var imageArray = [UIImage]()
//                // imageArray.removeAll()
//                for i in 0..<result1.count{
//
//                    let asset = result1.object(at: i)
//                    cell.representedAssetIdentifier = asset.localIdentifier
//                    // let imageSize = CGSize(width: asset.pixelWidth,height: asset.pixelHeight)
//                    let imageSize = CGSize(width: asset.pixelWidth/2, height: asset.pixelHeight/2)
//                    self.imageManager.requestImage(for:asset , targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
//                        // The cell may have been recycled by the time this handler gets called;
//                        // set the cell's thumbnail image only if it's still showing the same asset.
//                        if image != nil {
//                            print("imaaaag\(image!)")
//                            if cell.representedAssetIdentifier == asset.localIdentifier {
//
//
//                                imageArray.append(image!)
//                            }
//                        }
//                    })
//
//                }
            
                
                DispatchQueue.main.async {
                    print("imageArray\(self.imageArrayForSection1)")
                    if !self.imageArrayForSection1.isEmpty{
                        if self.imageArrayForSection1.count >  indexPath.row {
                            cell.albumImage.image = self.imageArrayForSection1[indexPath.row]
                            cell.photoCountsLabel.text = "\(self.userCount[indexPath.row])"
                        } else {
                             cell.albumImage.image = UIImage(named: "Empty-Folder-icon")
                        }
                        
                        //cell.albumImage.image = self.imageArrayForSection1[0]
                        
                    }else{
                        cell.albumImage.image = UIImage(named: "Empty-Folder-icon")
                    }
                    
                    
                    print("estimate count \(10)")
                    cell.photoCountsLabel.text = String("10")
                }
            
            
            
            cell.radioImageView.image = UIImage(named: "")
            //  cell.albumImage.image = UIImage(named: "pick-photo_03")
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoAlbumCollectionViewCell
            let collection = smartAlbums.object(at: indexPath.row)
            cell.albumImage.alpha = 1
            print("collection\(collection)")
            cell.albumNameLabel.text = collection.localizedTitle
//            DispatchQueue.global(qos: .background).async {
//                let fetchOptions = PHFetchOptions()
//                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//
//                let result1 = PHAsset.fetchAssets(in: collection, options: fetchOptions)
//                print("estimate count \(result1.count)")
//
//
//
//                //  print("imaaaag\(result1)")
//
//                var imageArray = [UIImage]()
//                //imageArray.removeAll()
//                for i in 0..<result1.count{
//
//                    let asset = result1.object(at: i)
//                    cell.representedAssetIdentifier = asset.localIdentifier
//
//                    let imageSize = CGSize(width: asset.pixelWidth,
//                                           height: asset.pixelHeight)
//                    self.imageManager.requestImage(for:asset , targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
//                        // The cell may have been recycled by the time this handler gets called;
//                        // set the cell's thumbnail image only if it's still showing the same asset.
//                        if image != nil {
//                            print("imaaaag\(image!)")
//                            if cell.representedAssetIdentifier == asset.localIdentifier {
//
//
//                                imageArray.append(image!)
//                            }
//                        }
//
//                    })
//
//
//                }
            
                DispatchQueue.main.async {
                    cell.photoCountsLabel.text = "40"
                 //   print("imageArray\(imageArray)")
                    if !self.imageArrayForSection2.isEmpty{
                        if self.imageArrayForSection2.count >  indexPath.row {
                        cell.albumImage.image = self.imageArrayForSection2[indexPath.row]
                            cell.photoCountsLabel.text = "\(self.smartCount[indexPath.row])"
                        } else {
                             cell.albumImage.image = UIImage(named: "Empty-Folder-icon")
                        }
                        
                    }else{
                        cell.albumImage.image = UIImage(named: "Empty-Folder-icon")
                    }
                }
                
       //     }
            
            
            
              return cell
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width: collectionView.frame.size.width / 2 - 22 , height:  collectionView.frame.size.width / 2 - 22)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let collection: PHCollection
        if indexPath.section == 0 {
              collection = userCollections.object(at: indexPath.row)
        } else {
             collection = smartAlbums.object(at: indexPath.row)
        }
        guard let assetCollection = collection as? PHAssetCollection
            else { fatalError("expected asset collection") }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        
     //   vc.foldername = cell.albumNameLabel.text
    //    DispatchQueue
        vc.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        vc.assetCollection = assetCollection
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension ViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
                // collectionView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue))
                
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
                
                //   collectionView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue))
            }
            
            
        }
    }
}
