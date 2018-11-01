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
    @IBOutlet weak var captionnTextField: UITextField!
    var gif: Gif?

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
