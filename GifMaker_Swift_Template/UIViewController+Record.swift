//
//  UIViewController+Record.swift
//  GifMaker_Swift_Template
//
//  Created by AlanChen on 2018/10/31.
//  Copyright © 2018年 Gabrielle Miller-Messner. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation

// Regif constants
let frameCount = 16
let delayTime: Float = 0.2
let loopConut = 0  // 0 means loop forever
let frameRate = 15;

extension UIViewController {
    @IBAction func presentVideoOptions(_ sender: UIButton) {
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            // launchPthotoLibrary
        } else {
            
            let newGifActionSheet = UIAlertController(title: "Create new GIF", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let recordVideo = UIAlertAction(title: "Record a Video", style: UIAlertActionStyle.default) { [weak self] (action) in
                self?.launchVideoCamera()
            }
            let chooseFromExisting = UIAlertAction(title: "Choose from Existing", style: UIAlertActionStyle.default) { [weak self] (action) in
//                self?.launchPhotoLibrary()
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            newGifActionSheet.addAction(recordVideo)
            newGifActionSheet.addAction(chooseFromExisting)
            newGifActionSheet.addAction(cancel)
            
            present(newGifActionSheet, animated: true, completion: nil)
            let pinkColor = UIColor(red: 255.0/255.0, green: 65.0/255.0, blue: 112.0/255.0, alpha: 1.0)
            newGifActionSheet.view.tintColor = pinkColor
        }
    }
    
    func launchVideoCamera() {
        // create imagePicker
        let recordVideoController = UIImagePickerController()
        // set properties: sourcetype, mediatypes, allowsEditing, delegate
        recordVideoController.sourceType = UIImagePickerControllerSourceType.camera
        recordVideoController.mediaTypes = [kUTTypeMovie as String]
        recordVideoController.allowsEditing = false
        recordVideoController.delegate = self
        // present controller
        self.present(recordVideoController, animated: true, completion: nil)
    }
    
    // MARK:  - Utils
    func pickerController(source: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.allowsEditing = true
        picker.delegate = self
        
        return picker
    }
}

// MARK: UINavigationControllerDelegate

extension UIViewController: UINavigationControllerDelegate {

}

// MARK: UIImagePickerControllerDelegate

extension UIViewController: UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String else {
            return
        }
        if mediaType == kUTTypeMovie as String {
            
            guard let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL else {
                return
            }
            let start: NSNumber? = info["_UIImagePickerControllerVideoEditingStart"] as? NSNumber
            let end: NSNumber? = info["_UIImagePickerControllerVideoEditingEnd"] as? NSNumber
            var duration: NSNumber?
            if let end = end, let start = start {
                duration = NSNumber(value: end.floatValue - start.floatValue)
            } else {
                duration = nil
            }
            cropVideoToGIF(rawVideoURL: videoURL, start: start, duration: duration)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func cropVideoToGIF(rawVideoURL: NSURL, start: NSNumber?, duration: NSNumber?) {
        //Create the AVAsset and AVAssetTrack
        let videoAsset = AVAsset(url: rawVideoURL as URL)
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        
        // Crop to square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTime(seconds: 1, preferredTimescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        // rotate to portrait
        let transformer = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
        let t1 = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: -(videoTrack.naturalSize.width - videoTrack.naturalSize.height) )
        let t2 = t1.rotated(by: CGFloat(M_PI_2))
        let finalTransform = t2
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        // export
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)
        exporter.videoComposition = videoComposition
        let path = self.createPath()
        exporter?.outputURL = NSURL(fileURLWithPath: path)
        
    }
    
    // MARK: GIF conversion methods
    func convertVideoToGIF(videoURL: NSURL, start: NSNumber?, duration: NSNumber?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        
        let regift: Regift
        
        if let start = start, let duration = duration {
            regift = Regift(sourceFileURL: videoURL as URL, startTime: start.floatValue, duration: duration.floatValue, frameRate: frameRate, loopCount: loopConut)
        } else {
            regift = Regift(sourceFileURL: videoURL as URL, frameCount: frameCount, delayTime: delayTime, loopCount: loopConut)
        }
        guard let gifURL = regift.createGif(), let url = gifURL as? NSURL else {
            return
        }
        
        let gif = Gif(url: url, videoURL: videoURL, caption: nil)
        displayGIF(gif: gif)
    }
    
    func displayGIF(gif: Gif) {
        guard let gifEditorVC = storyboard?.instantiateViewController(withIdentifier: "GifEditorViewController") as? GifEditorViewController else {
            return
        }
        gifEditorVC.gif = gif
        navigationController?.pushViewController(gifEditorVC, animated: true)
    }
}
