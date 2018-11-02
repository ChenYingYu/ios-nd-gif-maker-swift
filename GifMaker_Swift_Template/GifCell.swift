//
//  GifCell.swift
//  GifMaker_Swift_Template
//
//  Created by AlanChen on 2018/11/2.
//  Copyright © 2018年 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class GifCell: UICollectionViewCell {
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    func configureGif(gif: Gif) {
        gifImageView.image = gif.gifImage
    }
    
}
