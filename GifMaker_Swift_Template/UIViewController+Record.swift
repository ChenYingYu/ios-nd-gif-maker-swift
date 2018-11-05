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
        recordVideoController.allowsEditing = true
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
            
            guard let videoURL = info[UIImagePickerControllerMediaURL] as? URL else {
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
            cropVideoToSquare(rawVideoURL: videoURL, start: start, duration: duration)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func cropVideoToSquare(rawVideoURL: URL, start: NSNumber?, duration: NSNumber?) {
        //Create the AVAsset and AVAssetTrack
        let videoAsset = AVAsset(url: rawVideoURL)
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        
        // Crop to square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        // rotate to portrait
        let transformer = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
        let t1 = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: (videoTrack.naturalSize.width - videoTrack.naturalSize.height) )
        let t2 = t1.rotated(by: CGFloat(M_PI_2))
        let finalTransform = t2
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        // export
        guard let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        exporter.videoComposition = videoComposition
        let path = createPath()
        exporter.outputURL = URL(fileURLWithPath: path)
        exporter.outputFileType = AVFileTypeQuickTimeMovie

        exporter.exportAsynchronously { [weak self] in
            if let croppedURL = exporter.outputURL {
                self?.convertVideoToGIF(videoURL: croppedURL, start: start, duration: duration)
            }
        }
        
    }
    
    func createPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let manager = FileManager()
        var outputURL = documentsDirectory.appending("/output")
        do {
            try manager.createDirectory(atPath: outputURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        outputURL = outputURL.appending("output.mov")
        
        // Remove Existing File
        do {
            try manager.removeItem(atPath: outputURL)
        } catch let error {
            print(error)
        }
        
        return outputURL
    }
    
    func configureExportSession(_ session: AVAssetExportSession, withOutputURL outputURL: String, startMilliseconds start: Int, endMilliseconds end: Int) -> AVAssetExportSession {
        
        session.outputURL = URL(fileURLWithPath: outputURL)
        session.outputFileType = AVFileTypeQuickTimeMovie
        let timeRange = CMTimeRangeMake(CMTimeMake(Int64(start), 1000), CMTimeMake(Int64(end - start), 1000))
        session.timeRange = timeRange
        
        return session
    }
    
    // MARK: GIF conversion methods
    func convertVideoToGIF(videoURL: URL, start: NSNumber?, duration: NSNumber?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        
        let regift: Regift
        
        if let start = start, let duration = duration {
            regift = Regift(sourceFileURL: videoURL as URL, startTime: start.floatValue, duration: duration.floatValue, frameRate: frameRate, loopCount: loopConut)
        } else {
            regift = Regift(sourceFileURL: videoURL as URL, frameCount: frameCount, delayTime: delayTime, loopCount: loopConut)
        }
        guard let gifURL = regift.createGif() else {
            return
        }
        
        let gif = Gif(url: gifURL, videoURL: videoURL, caption: nil)
        displayGIF(gif: gif)
    }
    
    func displayGIF(gif: Gif) {
        guard let gifEditorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GifEditorViewController") as? GifEditorViewController else {
            return
        }
        gifEditorVC.gif = gif
        navigationController?.pushViewController(gifEditorVC, animated: true)
    }
}
