//
//  GifEditorViewController.swift
//  GifMaker_Swift_Template
//
//  Created by AlanChen on 2018/10/31.
//  Copyright © 2018年 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class GifEditorViewController: UIViewController {

    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    var gif: Gif?
    
    @IBAction func presentPreview(_ sender: Any) {
        guard let previewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController else {
            return
        }
        self.gif?.caption = self.captionTextField.text
        guard let sourceFileURL = self.gif?.videoURL else {
            return
        }
        let regfit = Regift(sourceFileURL: sourceFileURL as URL, destinationFileURL: nil, frameCount: frameCount, delayTime: delayTime, loopCount: loopConut)
        let captionFont = self.captionTextField.font
        guard let gifURL = regfit.createGif(self.captionTextField.text, font: captionFont) else {
            return
        }
        let newGif = Gif(url: gifURL, videoURL: sourceFileURL, caption: self.captionTextField.text)
        previewVC.gif = newGif
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gifImageView.image = gif?.gifImage
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
}

extension GifEditorViewController: UITextFieldDelegate {
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension GifEditorViewController {
    // MARK: Observe and respond to keyboard notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: Notification) {
        if (self.view.frame.origin.y >= 0) {
            self.view.frame.origin.y -= self.getKeyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if (self.view.frame.origin.y < 0) {
            self.view.frame.origin.y += self.getKeyboardHeight(notification: notification)
        }
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        if let userInfo = notification.userInfo, let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            return keyboardFrameEnd.size.height
        }
        return 0.0
    }
}
