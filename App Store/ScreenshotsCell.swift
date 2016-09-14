//
//  ScreenshotsCell.swift
//  App Store
//
//  Created by Jorge Casariego on 8/9/16.
//  Copyright © 2016 Jorge Casariego. All rights reserved.
//

import UIKit

class ScreenshotsCell: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var app: App? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let cellId = "cedllId"
    
    let collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        return cv
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()

    
    override func setupViews() {
        super.setupViews()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubview(collectionView)
        addSubview(dividerView)
        
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        
        addConstraintsWithFormat("H:|-14-[v0]|", views: dividerView)
        
        addConstraintsWithFormat("V:|[v0][v1(1)]|", views: collectionView, dividerView)
        
        collectionView.register(ScreenshotImageCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = app?.screenshots?.count {
            return count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotImageCell
        
        if let imageName = app?.screenshots?[(indexPath as NSIndexPath).item] {
            cell.imageView.image = UIImage(named: imageName)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: frame.height-28)
    }
    
    // Agregamos padding a la derechea y a la izquierda
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 14, 0, 14)
    }
    
    fileprivate class ScreenshotImageCell: BaseCell {
        
        let imageView: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.backgroundColor = UIColor.green
            return iv
        }()
        
        fileprivate override func setupViews() {
            super.setupViews()
            
            // Si no ponemos esto las imagenes se superponen completamente.
            layer.masksToBounds = true
            
            addSubview(imageView)
            addConstraintsWithFormat("H:|[v0]|", views: imageView)
            addConstraintsWithFormat("V:|[v0]|", views: imageView)
            
        }
    }
}
