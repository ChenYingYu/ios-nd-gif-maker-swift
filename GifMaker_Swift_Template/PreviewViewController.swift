//
//  PreviewViewController.swift
//  GifMaker_Swift_Template
//
//  Created by AlanChen on 2018/10/31.
//  Copyright © 2018年 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView!
    var gif: Gif?
    
    @IBAction func shareGif(_ sender: UIButton) {
        guard let gifURL = self.gif?.url else {
            return
        }
        guard let animatedGif = NSData(contentsOf: gifURL as URL) else {
            return
        }
        let itemsToShare: [Any] = [animatedGif]
        let shareController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        shareController.completionWithItemsHandler = {(activity, completed, returnItems, error) in
            if (completed) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        self.present(shareController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        previewImageView.image = gif?.gifImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
