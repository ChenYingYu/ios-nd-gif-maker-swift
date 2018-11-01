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
    @IBAction func launchVideoCamera(sender: AnyObject) {
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
            guard let videoURL = info[UIImagePickerControllerMediaURL] as? URL else {
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
    func convertVideoToGIF(videoURL: URL) {
        let regift = Regift(sourceFileURL: videoURL, frameCount: frameCount, delayTime: delayTime, loopCount: loopConut)
        guard let gifURL = regift.createGif() else {
            return
        }
        
        displayGIF(url: gifURL as NSURL)
    }
    
    func displayGIF(url: NSURL) {
        guard let gifEditorVC = storyboard?.instantiateViewController(withIdentifier: "GifEditorViewController") as? GifEditorViewController else {
            return
        }
        gifEditorVC.gifURL = url
        navigationController?.pushViewController(gifEditorVC, animated: true)
    }
}
