//
//  SavedGifsViewController.swift
//  GifMaker_Swift_Template
//
//  Created by AlanChen on 2018/11/2.
//  Copyright © 2018年 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class SavedGifsViewController: UIViewController, PreviewViewControllerDelegate {
    
    var savedGifs = [Gif]()
    let cellMargin: CGFloat = 12.0
    @IBOutlet weak var gifCollectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
        
        emptyView.isHidden = (savedGifs.count != 0)
        gifCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpCollectionView()
    }
    
    func previewVC(preview: UIViewController, didSaveGif gif: Gif) {
        savedGifs.append(gif)
    }
}

extension SavedGifsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setUpCollectionView() {
        gifCollectionView.delegate = self
        gifCollectionView.dataSource = self
    }
    
    // MARK: CollectionView Delegate and Datasource Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
//            savedGifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as? GifCell else {
            return GifCell()
        }
//        let gif = savedGifs[indexPath.row]
//        cell.configureGif(gif: gif)
        return cell
    }
    
    // MARK: CollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - (cellMargin * 2.0)) / 2.0
        return CGSize(width: width, height: width)
    }
}
