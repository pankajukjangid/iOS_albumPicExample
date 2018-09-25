//
//  PhotosViewController.swift
//  PICMOB
//
//  Created by Mohit Singh on 8/9/18.
//  Copyright © 2018 Mohit Singh. All rights reserved.
//

import UIKit
import Photos
import CoreData
import PhotosUI
import SVProgressHUD
class PhotosViewController: UIViewController {

    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var folderNameLabel: UILabel!
    var foldername:String!
    
    
    var images = [UIImage]()
    var selectArray = [String]()
    var imageName = [String]()
    
    
    var aCIImage = CIImage()
    var brightnessFilter: CIFilter!
    var context = CIContext()
    var outputImage = CIImage()
    var newUIImage = UIImage()
    
    var clickedIndex = 0
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    @IBOutlet var addButtonItem: UIBarButtonItem!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    var photoAssets = PHFetchResult<AnyObject>()
    
    
    var imagePath = [String]()
   override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//
//    if AppHelper.getBoolForKey(ServiceKeys.vcIsSelect) != true{
//
//
//        AppHelper.setBoolForKey(true, key: ServiceKeys.vcIsSelect)
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "SelectInformationViewController") as! SelectInformationViewController
//        self.present(vc, animated: true, completion: nil)
//
//
//    }
    
    
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    let scale = UIScreen.main.scale
    //let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    thumbnailSize = CGSize(width: 100.0 * scale, height: 100.0 * scale)
    
    
    }
    
    
    func hudShow()  {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
    }
    func hudHide()  {
        SVProgressHUD.dismiss()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
            nextButton.alpha = 0.6
            nextButton.isEnabled = false
        
        
     //    self.navTitle.text = "Selected Photos 0"
        self.folderNameLabel.text = foldername
        
        print("follllll\(foldername)")
      //  self.FetchCustomAlbumPhotos(folderName: foldername)

        
        print("imagesimagesimagesimages\(images)")
        // Do any additional setup after loading the view.
        
        
       
        
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.2
        longPressGR.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressGR)
     //   self.hudShow()
        autoreleasepool {
        DispatchQueue.global(qos: .background).async {
            self.fatchImagesfromAlbum()
        }
        }
      
        
    }
    
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        URLCache.shared.removeAllCachedResponses()
    }
    
    
    
    func fatchImagesfromAlbum() {
        
        photoAssets = fetchResult as! PHFetchResult<AnyObject>
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        //
        
        photoAssets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions) as! PHFetchResult<AnyObject>
        
        for i in 0..<photoAssets.count{
            
            
            //
            let asset = photoAssets.object(at: i)
            
            let imageSize = CGSize(width: asset.pixelWidth,
                                   height: asset.pixelHeight)
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.isSynchronous = true
            
         
            imageManager.requestImage(for: asset as! PHAsset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: { (image, info) -> Void in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                // if cell.representedAssetIdentifier == asset.localIdentifier {
                //   cell.thumbnailImage = image
                
                self.images.append(image!)
                let url:NSURL = info!["PHImageFileURLKey"] as! NSURL
                let urlString: String = url.absoluteString!
                let theFileName = (urlString as NSString).lastPathComponent
                print("file name\(info!)")
                self.imageName.append("\(theFileName)")
                self.imagePath.append(urlString)
                
                
                //}
            })
            
            print(self.imagePath)
            print("========================================================")
            print(self.imageName)
            // self.images.append(UIImage(named: "pick-photo_03")!)
            // self.imageName.append("0")
            //    self.imagePath.append("0")
            
            
                DispatchQueue.main.sync {
                    self.collectionView.reloadData()
            }
        
        }
        
        for i in 0..<images.count{
            selectArray.append("0")
        }
        //
        
        //      self.fetchData()
        
      
       
        print("fetchResult\(fetchResult)")
        print("assetCollection\(assetCollection)")
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // If we get here without a segue, it's because we're visible at app launch,
        // so match the behavior of segue from the default "All Photos" view.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
    
        
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
//
//        let storybard = UIStoryboard(name: "Main", bundle: nil)
//
//        let vc = storybard.instantiateViewController(withIdentifier: "SelectParametersViewController") as! SelectParametersViewController
//
//        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    
    var count:Int = 0
    
    @IBAction func selectAllClicked(_ sender: UIButton) {
        
        
       // if sender.title(for: .normal) == "Select All"{
        for  i in 0..<images.count{
            selectArray[i] = "1"
         //
            
       //      addImagetoDatabase(index:i,status:1)
            
            
        //     self.navTitle.text = "Selected Photos \(selectArray.count)"
            count = selectArray.count
        }
     
        if selectArray.contains("1"){
            nextButton.alpha = 1
            nextButton.isEnabled = true
        }else{
            nextButton.alpha = 0.6
            nextButton.isEnabled = false
        }
        
        self.collectionView.reloadData()
        
            //sender.setTitle("Deselect All", for: .normal)
    //}
      /*  else{
            
            for  i in 0..<images.count{
                selectArray[i] = "0"
                self.collectionView.reloadData()
                
                self.navTitle.text = "Selected Photos \(selectArray.count)"
                count = selectArray.count
            }
            
            //sender.setTitle("Select All", for: .normal)
            
            
            
        }
      */
        
        
    }
    
    
    var fetchedImage = [String]()
    
//    func fetchData(){
//
//     //   fetchedImage.removeAll()
//
//        let fetchRequest1:NSFetchRequest<UserImages> = UserImages.fetchRequest()
//        fetchRequest1.predicate = NSPredicate.init(format: "orderid == %@", AppHelper.getStringForKey(databaseKeys.orderId))
//        do{
//
//            let searchResult = try DatabaseController.getContext().fetch(fetchRequest1)
//
//            for result in searchResult as [UserImages]
//            {
//
//                fetchedImage.append(result.imageName!)
//
//            }
//
//        }
//        catch
//        {
//            print("Error: \(error)")
//        }
//
//        print("aa\(fetchedImage)")
//    }
    
    


}

extension PhotosViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // return images.count
        
        // return photoAssets.count
        if imagePath.count > 0 {
        return self.imagePath.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
        //cell.albumImage.image = images[indexPath.row]
       //
      //  let asset = photoAssets.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCollectionViewCell", for: indexPath) as! PhotosCollectionViewCell
        let asset = photoAssets.object(at: indexPath.item)
//        let url = URL(fileURLWithPath: imagePath[indexPath.row])
//
//        let imageData = NSData(contentsOf: url)
        
     //   let image = UIImage(data: imageData as! Data)
       //  cell.thumbnailImage = image
       // cell.thumbnailImage = self.images[indexPath.row]
        
      //  let imageData:NSData = NSData(contentsOf: URL(fileURLWithPath: self.imagePath[indexPath.row]))!
        
        let image = UIImage(contentsOfFile: self.imagePath[indexPath.row])
        
        cell.thumbnailImage = image
        
        cell.representedAssetIdentifier = asset.localIdentifier
        print(self.imagePath[indexPath.row])
        
//        if self.selectArray[indexPath.row] == "0"{
//            cell.selectImageView.image = UIImage(named: "")
//
//            cell.albumImage.alpha = 1
//
//        }
//        else{
//
//            cell.albumImage.alpha = 0.6
//
//            cell.selectImageView.image = UIImage(named: "selectRadio")
//
//
//        }
   
        
        return  cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCollectionViewCell", for: indexPath) as! PhotosCollectionViewCell
           let asset = photoAssets.object(at: indexPath.item)
          cell.thumbnailImage = self.images[indexPath.row]
           cell.representedAssetIdentifier = asset.localIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 2 - 22, height: UIScreen.main.bounds.width / 2 - 22)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotosCollectionViewCell
        
        
        if cell.selectImageView.image == UIImage(named: ""){
            cell.selectImageView.image = UIImage(named: "selectRadio")
            selectArray[indexPath.row] = "1"
            
            count = count + 1
            cell.albumImage.alpha = 0.6
            
           
            
         //   self.addImagetoDatabase(index: indexPath.row, status: 1)
            
            
        }
        else{
            cell.albumImage.alpha = 1
            cell.selectImageView.image = UIImage(named: "")
            selectArray[indexPath.row] = "0"
            
            count = count - 1
            
          
           // self.addImagetoDatabase(index: indexPath.row, status: 0)
        }
        
        
//         self.navTitle.text = "Selected Photos \(count)"
        
         clickedIndex = indexPath.row
        
        if selectArray.contains("1"){
            nextButton.alpha = 1
            nextButton.isEnabled = true
        }else{
            nextButton.alpha = 0.6
            nextButton.isEnabled = false
        }
        
        
    /*    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        cell.addGestureRecognizer(doubleTap)
      */
        
       /* let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        clickedIndex = indexPath.row
        singleTap.numberOfTapsRequired = 1
        cell.addGestureRecognizer(singleTap)*/
        
        
        
    }
    
    
    
//    func addImagetoDatabase(index:Int,status:Int){
//        var id = [String]()
//        var finalId: Int!
//
//        let fetchRequest:NSFetchRequest<UserImages> = UserImages.fetchRequest()
//        do{
//
//            let searchResult = try DatabaseController.getContext().fetch(fetchRequest)
//            for result in searchResult as [UserImages]
//            {
//
//
//                print("User Cart orderid \(result.image_name!) id \(result.id!)")
//
//                print("\(AppHelper.getStringForKey(databaseKeys.orderId))")
//                id.append(result.orderid!)
//            }
//
//            if id.count < 1{
//                finalId = 1
//
//            }
//            else{
//
//                finalId =  id.count + 1
//
//            }
//
//            if status == 1{
//                let imageInData = UIImageJPEGRepresentation(images[index], 1.0)
//
//                let userImages = NSEntityDescription.insertNewObject(forEntityName: "UserImages", into: DatabaseController.getContext()) as! UserImages
//
//                userImages.id = String(finalId)
//                userImages.orderid = AppHelper.getStringForKey(databaseKeys.orderId)
//
//                userImages.imageBinary = imageInData! as NSData
//                userImages.qty = "1"
//                userImages.imageName = self.imageName[index]
//                userImages.isOrderComplete = "no"
//                userImages.imagePath = self.imagePath[index]
//                DatabaseController.saveContext()
//
//
//            }else{
//
//                let context = DatabaseController.getContext()
//                let coord = DatabaseController.getContext().persistentStoreCoordinator
//                let fetchRequest:NSFetchRequest<UserImages> = UserImages.fetchRequest()
//                fetchRequest.predicate = NSPredicate.init(format: "imageName == %@", self.imageName[index])
//                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as!
//                    NSFetchRequest<NSFetchRequestResult>)
//                do {
//                    try coord?.execute(deleteRequest, with: context)
//
//                } catch let error as NSError {
//                    debugPrint(error)
//                }
//
//            }
//
//
//
//
//
//
//
//
//        }
//        catch
//        {
//            print("Error: \(error)")
//        }
//
//
//        /*
//        let context = DatabaseController.getContext()
//        let coord = DatabaseController.getContext().persistentStoreCoordinator
//        let fetchRequest1:NSFetchRequest<UserImages> = UserImages.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest1 as!
//            NSFetchRequest<NSFetchRequestResult>)
//        do {
//            try coord?.execute(deleteRequest, with: context)
//
//        } catch let error as NSError {
//            debugPrint(error)
//        }*/
//
//    }
    
   
    
    
    @objc func doubleTapped() {
        // do something here
        
    }
    
    @objc func singleTapped() {
        // do something here
         print("single tap\(clickedIndex)")
    }

    
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {

    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    // MARK: UI Actions
    
    @IBAction func addAsset(_ sender: AnyObject?) {
        
        // Create a dummy image of a random solid color and random orientation.
        let size = (arc4random_uniform(2) == 0) ?
            CGSize(width: 400, height: 300) :
            CGSize(width: 300, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(hue: CGFloat(arc4random_uniform(100))/100,
                    saturation: 1, brightness: 1, alpha: 1).setFill()
            context.fill(context.format.bounds)
        }
        
        // Add it to the photo library.
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let assetCollection = self.assetCollection {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            }
        }, completionHandler: {success, error in
            if !success { print("error creating asset: \(error)") }
        })
    }
    
    
}
private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}



// MARK: PHPhotoLibraryChangeObserver
extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
}


