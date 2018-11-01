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

// Regif constants
let frameCount = 16
let delayTime: Float = 0.2
let loopConut = 0  // 0 means loop forever

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
            dismiss(animated: true, completion: nil)
            guard let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL else {
                return
            }
            convertVideoToGIF(videoURL: videoURL)
            
//            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: GIF conversion methods
    func convertVideoToGIF(videoURL: NSURL) {
        let regift = Regift(sourceFileURL: videoURL as URL, frameCount: frameCount, delayTime: delayTime, loopCount: loopConut)
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
