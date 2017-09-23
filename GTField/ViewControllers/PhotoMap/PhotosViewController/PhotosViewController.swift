//
//  PhotosViewController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The secondary view controller used for browing the photos.
 */

import UIKit
//import AEXML
import Photos
import MessageUI

@objc(PhotosViewController)
class PhotosViewController: UIViewController, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    var photosToShow: [PhotoAnnotation] = []
    var pageAnimationFinished: Bool = false
    
    private lazy var modelController: ModelController = ModelController()
    private var pageViewController: UIPageViewController?
    private var buttonAction: UIBarButtonItem?
    private var dataViewController: DataViewController?

    //#MARK: -
    
    private func updateNavBarTitle() {
        
        if self.modelController.pageData.count > 1 {
            self.title = NSLocalizedString("Photos", comment: "") + " (\(self.modelController.currentPageIndex + 1) "+NSLocalizedString("of", comment: "")+" \(self.modelController.pageData.count))"
        } else {
            self.title = self.photosToShow[self.modelController.currentPageIndex].imgName
        }
        self.dataViewController = self.modelController.dataViewController
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView(currentPageIndex: 0)
        
        self.buttonAction = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(btnAction(_:)))
        self.buttonAction?.tag = 1
        self.navigationItem.rightBarButtonItem = self.buttonAction
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Bổ sung setupView với currentPageIndex để hiển thị sau khi xóa ảnh
    // Khi có nhiều ảnh thì có thể ảnh hưởng đến việc hiển thị do quá trình trong hàm này
    // Nếu cần thiết thì có thể cải tiến
    func setupView(currentPageIndex: Int) {
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        pageViewController =
            UIPageViewController(transitionStyle: .pageCurl,
                                 navigationOrientation: .horizontal,
                                 options: nil)
        self.pageViewController!.delegate = self
        
        // Bổ sung
        self.modelController = ModelController()
        self.modelController.currentPageIndex = currentPageIndex
        
        self.modelController.pageData = self.photosToShow
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let startingViewController = self.modelController.viewControllerAtIndex(currentPageIndex, storyboard: storyboard)!
        
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers,
                                                    direction: .forward,
                                                    animated: false,
                                                    completion: nil)
        
        self.updateNavBarTitle()
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMove(toParentViewController: self)
        
        // add the page view controller's gesture recognizers to the book view controller's view
        // so that the gestures are started more easily
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
        pageAnimationFinished = true
    }
    
    @IBAction func btnAction(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 10: // Save title
            self.dataViewController?.poiTitle = self.dataViewController?.txtTitle.text
            self.dataViewController?.txtTitle.isEnabled = false
            self.dataViewController?.txtTitle.resignFirstResponder()
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = self.buttonAction
            break
        case 11: // Cancel title
            self.dataViewController?.txtTitle.text = self.dataViewController?.poiTitle
            self.dataViewController?.txtTitle.isEnabled = false
            self.dataViewController?.txtTitle.resignFirstResponder()
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = self.buttonAction
            break
        case 12: // Save description
            self.dataViewController?.poiDesc = self.dataViewController?.txtDesc.text
            self.dataViewController?.txtDesc.isEditable = false
            self.dataViewController?.txtDesc.resignFirstResponder()
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = self.buttonAction
            break;
        case 13: // Cancel description
            self.dataViewController?.txtDesc.text = self.dataViewController?.poiDesc
            self.dataViewController?.txtDesc.isEditable = false
            self.dataViewController?.txtDesc.resignFirstResponder()
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = self.buttonAction
            break
        default: // Actions
            // Nên khống chế số lượng ảnh < 50 khi export gpx
            let count = self.photosToShow.count
            let alertController = UIAlertController(title: NSLocalizedString("Select option", comment: ""), message: nil, preferredStyle: .actionSheet)
            let editPhotoTitleButton = UIAlertAction(title: NSLocalizedString("Edit this photo title", comment: ""), style: .default, handler: { (action) -> Void in
                self.editPhotoTitle()
            })
            let editPhotoDescButton = UIAlertAction(title: NSLocalizedString("Edit this photo description", comment: ""), style: .default, handler: { (action) -> Void in
                self.editPhotoDesc()
            })
            
            let exportGPXButton = UIAlertAction(title: NSLocalizedString("Export all", comment: "")+" (\(count)) "+NSLocalizedString("photo's location to GPX", comment: ""), style: .default, handler: { (action) -> Void in
                
                DispatchQueue.global().async() {
                    self.dataViewController?.view.showLoading()
                }
                
                let xmlRequest = AEXMLDocument()
                let gpxAttributes = ["version":"1.1","creator":"\(APP_FULL_NAME)"]
                let gpx = xmlRequest.addChild(name: "gpx", attributes: gpxAttributes)
                let metadata = GPXMetadata()
                metadata.desc = "Photos location"
                let fileName = metadata.name
                let gpxFileUrl = createDocumentFileFor(subPath: "", fileName: fileName, ext: "")
                
                gpx.addChild(metadata.root)
                
                gpx.addChild(name: "name")
                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = 8
                
                for photo in self.photosToShow {
                    queue.addOperation {
                        gpx.addChild(photo.wptWithPhoto!)
                    }
                }
                queue.waitUntilAllOperationsAreFinished()
                
                try! xmlRequest.xml.write(to: gpxFileUrl, atomically: true, encoding: .utf8)
                
                //DispatchQueue.main.async() {
                    self.dataViewController?.imgPoi.hideLoading()
                //}
                // TODO: email
                self.actionSendEmail(gpxFileUrl)
            })
            
            let savePhotoButton = UIAlertAction(title: NSLocalizedString("Save this photo to Camera Roll", comment: ""), style: .default, handler: { (action) -> Void in
                let currentPhoto = self.photosToShow[self.modelController.currentPageIndex]
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: currentPhoto.imagePath!))
                }) { saved, error in
                    if saved {
                        let alertController = UIAlertController(title: NSLocalizedString("Your photo was successfully saved", comment: ""), message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: NSLocalizedString("Save Error!", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            })
            let savePhotosButton = UIAlertAction(title: NSLocalizedString("Save all", comment: "") + " (\(count)) "+NSLocalizedString("photos to Camera Roll", comment: ""), style: .default, handler: { (action) -> Void in
                // TODO: xem xét xử lý các cluster
                var saveCounter = 0
                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = 8
                
                for photo in self.photosToShow {
                    queue.addOperation {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: photo.imagePath!))
                        }) { saved, error in
                            if saved {
                                saveCounter += 1
                            }
                        }
                    }
                }
                queue.waitUntilAllOperationsAreFinished()
                
                let alertController = UIAlertController(title: NSLocalizedString("All your photos was successfully saved", comment: ""), message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            })
            
            let  deletePhotoButton = UIAlertAction(title: NSLocalizedString("Delete this photo forever", comment: ""), style: .destructive, handler: { (action) -> Void in
                self.deletePhoto(sender)
            })
            
            let  deletePhotosButton = UIAlertAction(title: NSLocalizedString("Delete  all", comment: "")+" (\(count)) "+NSLocalizedString("photos forever", comment: ""), style: .destructive, handler: { (action) -> Void in
                self.deletePhotos(sender)
            })
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) -> Void in
                
            })
            
            alertController.addAction(editPhotoTitleButton)
            alertController.addAction(editPhotoDescButton)
            alertController.addAction(exportGPXButton)
            alertController.addAction(savePhotoButton)
            if count > 1 {
                alertController.addAction(savePhotosButton)
            }
            alertController.addAction(deletePhotoButton)
            if count > 1 {
                alertController.addAction(deletePhotosButton)
            }
            alertController.addAction(cancelButton)
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.barButtonItem = sender
                }
            }
            self.present(alertController, animated: true, completion: nil)
            break
        }
    }
    
    func editPhotoTitle() {
        self.dataViewController?.txtTitle.isEnabled = true
        self.dataViewController?.txtTitle.becomeFirstResponder()
        
        // back button = cancel, right button = save
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.btnAction(_:)))
        saveButton.tag = 10
        self.navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.btnAction(_:)))
        cancelButton.tag = 11
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func editPhotoDesc() {
        self.dataViewController?.txtDesc.isEditable = true
        self.dataViewController?.txtDesc.becomeFirstResponder()
        
        // back button = cancel, right button = save
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.btnAction(_:)))
        saveButton.tag = 12
        self.navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.btnAction(_:)))
        cancelButton.tag = 13
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func deletePhoto(_ sender: Any?) {
        let alert = UIAlertController(
            title: NSLocalizedString("Warning delete", comment: ""),
            message: NSLocalizedString("This photo will be deleted from this app on your device", comment: ""),
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel,
            handler: { (action: UIAlertAction!) in
                // Cancel
        }))
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default,
            handler: { (action: UIAlertAction!) in
                // Gỡ photoshow
                var currentPageIndex = self.modelController.currentPageIndex
                let currentPhoto = self.photosToShow[currentPageIndex]
                if currentPageIndex == self.photosToShow.count - 1 {
                    currentPageIndex -= 1
                }
                
                self.pageAnimationFinished = false
                self.photosToShow.remove(at: self.modelController.currentPageIndex)
                
                // Kiểm tra nếu không còn photo nào thì dismiss
                if self.photosToShow.count > 0 {
                    self.setupView(currentPageIndex: currentPageIndex)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                
                // Gọi hàm xóa để gỡ khỏi mapView và xóa đường dẫn ảnh
                // Đã bổ sung mapView và allAnnotationMapView vào PhotoAnnotation để kiểm soát việc xóa
                currentPhoto.delete(all: false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func deletePhotos(_ sender: Any?) {
        let count = self.photosToShow.count
        
        let alert = UIAlertController(
            title: NSLocalizedString("Warning delete", comment: ""),
            message: "\(count) "+NSLocalizedString("photos will be deleted from this app on your device", comment: ""),
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel,
            handler: { (action: UIAlertAction!) in
                // Cancel
        }))
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default,
            handler: { (action: UIAlertAction!) in
                if count == 1 {
                    self.deletePhoto(nil)
                    return
                }
                for photo in self.photosToShow {
                    photo.delete(all: false)
                }
                self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    internal func actionSendEmail(_ fileURL: URL) {
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        if MFMailComposeViewController.canSendMail() {
            // set the subject
            composer.setSubject("[\(APP_NAME)] " + NSLocalizedString("Export photo's location to GPX file", comment: ""))
            
            //Add some text to the body and attach the file
           let body = "\(APP_FULL_NAME). " + NSLocalizedString("You can copy your files between your computer and apps on your iOS device using File Sharing.", comment: "") + " https://support.apple.com/en-us/HT201301<br />"
            
            composer.setMessageBody(body, isHTML: true)
            //composer.setToRecipients(["chuyentt@gmail.com"])
            do {
                let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                composer.addAttachmentData(fileData, mimeType:"application/gpx+xml", fileName: fileURL.lastPathComponent)
            } catch {
                
            }
            if let nav = self.navigationController {
                nav.present(composer, animated: true, completion: nil)
            } else {
                self.present(composer, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertView(title: NSLocalizedString("No email accounts configured", comment: ""), message: NSLocalizedString("Please add a mail account in Settings to send mail from, by Go to Settings > Mail > Accounts > Add Account", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
            alert.show()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let alert: UIAlertController
        switch result.rawValue {
        case MFMailComposeResult.sent.rawValue:
            alert = UIAlertController(
                title: NSLocalizedString("Sent", comment: ""),
                message: error?.localizedDescription,
                preferredStyle: UIAlertControllerStyle.alert
            )
            break
        default:
            alert = UIAlertController(
                title: NSLocalizedString("Whoops", comment: ""),
                message: error?.localizedDescription,
                preferredStyle: UIAlertControllerStyle.alert
            )
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .default, handler: nil))
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    
    
    //#MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        
        // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        let currentViewController = self.pageViewController!.viewControllers![0]
        
        let viewControllers = [currentViewController]
        self.pageViewController!.setViewControllers(viewControllers,
            direction: .forward,
            animated: true,
            completion: nil)
        
        self.pageViewController!.isDoubleSided = false
        return .min
    }
    
    // Slide 4 >>
    // << Slide back 4
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pageAnimationFinished = false
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // update the nav bar title showing which index we are displaying
        self.updateNavBarTitle()
        
        pageAnimationFinished = true
    }
}
