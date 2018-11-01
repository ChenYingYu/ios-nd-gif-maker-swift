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
    var gifURL: NSURL? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let gifURL = gifURL, let urlString = gifURL.absoluteString, let gifFromRecording = UIImage.gif(url: urlString) {
            gifImageView.image = gifFromRecording
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
