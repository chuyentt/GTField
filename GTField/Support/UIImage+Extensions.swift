//
//  UIImage+Extensions.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/10/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import ImageIO
import CoreLocation

extension UIImage {
    func fixOrientation() -> UIImage {
        // No-op if the orientation is already correct
        guard self.imageOrientation != .up else {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch (self.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi/2)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -CGFloat.pi/2)
            
        default:
            break
        }
        
        switch (self.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                            bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                            space: self.cgImage!.colorSpace!,
                            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)
        switch (self.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        if let cgImage = ctx!.makeImage() {
            return UIImage(cgImage: cgImage)
        } else {
            return self
        }
    }
    
    func cropToSize(size: CGSize) -> UIImage {
        let refWidth: CGFloat = CGFloat((self.cgImage?.width)!)
        let refHeight: CGFloat = CGFloat((self.cgImage?.height)!)
        let width = refWidth < refHeight ? refWidth : refHeight
        let scale = size.width > size.height ? width / size.width : width / size.height
        let newSize = CGSize(width: scale * size.width, height: scale * size.height)
        let x = (refWidth - newSize.width) / 2.0
        let y = (refHeight - newSize.height) / 2.0
        let cropRect = CGRect(x: x, y: y, width: newSize.width, height: newSize.height)
        let imageRef = self.cgImage!.cropping(to: cropRect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: .up)
        return image
    }
    
    func cropImage(cropSize: CGSize) -> UIImage {
        //calculate scale factor to go between cropframe and original image
        let SF = size.width < size.height ? size.width / cropSize.width : size.height / cropSize.height
        //find the centre x,y coordinates of image
        let centreX = size.width / 2
        let centreY = size.height / 2
        //calculate crop parameters
        let cropX = centreX - ((cropSize.width / 2) * SF)
        let cropY = centreY - ((cropSize.height / 2) * SF)
        let cropRect = CGRect(x: CGFloat(cropX), y: CGFloat(cropY), width: CGFloat((cropSize.width * SF)), height: CGFloat((cropSize.height * SF)))
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: .pi/2).translatedBy(x: 0, y: -size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: -.pi/2).translatedBy(x: -size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: -.pi).translatedBy(x: -size.width, y: -size.height)
        default:
            rectTransform = CGAffineTransform.identity
        }
        
        rectTransform = rectTransform.scaledBy(x: scale, y: scale)
        let imageRef: CGImage? = cgImage?.cropping(to: cropRect.applying(rectTransform))

        let result = UIImage(cgImage: imageRef!, scale: scale, orientation: imageOrientation)
        
        return result.fixOrientation()
    }
    
    func changeToSize(size: CGSize) -> UIImage {
        var newSize = size
        newSize.width /= self.scale
        newSize.height /= self.scale
        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        var thumbnailRect = CGRect()
        thumbnailRect.origin = CGPoint()
        thumbnailRect.size.width = size.width
        thumbnailRect.size.height = size.height
        self.draw(in: thumbnailRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if imageOrientation == .left,
            imageOrientation == .right { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if imageOrientation == .up,
            imageOrientation == .down { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        UIGraphicsBeginImageContextWithOptions(to, true, self.scale)
        cropped.draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized!
    }
}
