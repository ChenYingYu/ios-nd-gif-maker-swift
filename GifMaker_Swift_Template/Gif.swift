//
//  Gif.swift
//  GifMaker_Swift_Template
//
//  Created by AlanChen on 2018/11/1.
//  Copyright © 2018年 Gabrielle Miller-Messner. All rights reserved.
//

import Foundation
import UIKit

class Gif {
    let url: URL
    var caption: String?
    let gifImage: UIImage?
    let videoURL: URL
    var gifData: NSData?
    
    init(url:URL, videoURL:URL, caption: String?) {
        self.url = url
        self.videoURL = videoURL
        self.caption = caption
        self.gifImage = UIImage.gif(url: url.absoluteString ?? "")
        self.gifData = nil
    }
}
