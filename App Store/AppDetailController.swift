//
//  AppDetailController.swift
//  App Store
//
//  Created by Jorge Casariego on 7/9/16.
//  Copyright © 2016 Jorge Casariego. All rights reserved.
//

import UIKit

class AppDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var app: App? {
        didSet {
            
            // Una vez que seteemos self.app = appDetail ya no va a volver a llamar el Web Service por eso se hace este control aquí. Sino estaríamos llamando infinitas veces
            if app?.screenshots != nil {
                return
            }
            
            if let id = app?.id {
                let urlString = "http://www.statsallday.com/appstore/appdetail?id=\(id)"
                
                NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data, response, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    do {
                        
                        let json = try(NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers))
                        
                        let appDetail = App()
                        appDetail.setValuesForKeysWithDictionary(json as! [String: AnyObject])
                        
                        self.app = appDetail
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.collectionView?.reloadData()
                        })
                        
                    } catch let err {
                        print(err)
                    }

                }).resume()
            }
        
        }
    }
    private let headerId = "headerId"
    private let cellId = "cellId"
    private let descriptionCellId = "descriptionCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(AppDetailHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.registerClass(ScreenshotsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.registerClass(AppDetailDescriptionCell.self, forCellWithReuseIdentifier: descriptionCellId)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(descriptionCellId, forIndexPath: indexPath) as! AppDetailDescriptionCell
            
            cell.textView.attributedText = descriptionAttributedText()
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ScreenshotsCell
        
        cell.app = app
        
        return cell
    }
    
    private func descriptionAttributedText() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Description\n", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)])
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let range = NSMakeRange(0, attributedText.string.characters.count)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: style, range: range)
        
        if let desc = app?.desc {
            attributedText.appendAttributedString(NSAttributedString(string: desc, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(11), NSForegroundColorAttributeName: UIColor.darkGrayColor()]))
        }
        
        return attributedText
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Esto sirve para hacer que la celda de la descripción sea solo el alto que ocupa el texto. O sea, hacemos que esto sea dinamico dependiendo de la descripción.
        if indexPath.item == 1 {
            let dummySize = CGSizeMake(view.frame.width - 8 - 8, 1000)
            let options = NSStringDrawingOptions.UsesFontLeading.union(NSStringDrawingOptions.UsesLineFragmentOrigin)
            let rect = descriptionAttributedText().boundingRectWithSize(dummySize, options: options, context: nil)
            
            return CGSizeMake(view.frame.width, rect.height + 40)
        }
        
        return CGSizeMake(view.frame.width, 170)
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerId, forIndexPath: indexPath) as! AppDetailHeader
        
        header.app = app
        
        return header
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(view.frame.width, 170)
    }
}

class AppDetailDescriptionCell: BaseCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE"
        return tv
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textView)
        addSubview(dividerView)
        
        addConstraintsWithFormat("H:|-8-[v0]-8-|", views: textView)
        addConstraintsWithFormat("H:|-14-[v0]|", views: dividerView)
        
        addConstraintsWithFormat("V:|-4-[v0]-4-[v1(1)]|", views: textView, dividerView)
    }
}

class AppDetailHeader: BaseCell {
    
    var app: App? {
        didSet {
            if let imageName = app?.imageName {
                imageView.image = UIImage(named: imageName)
            }
            
            nameLabel.text = app?.name
            
            if let price = app?.price?.stringValue {
                buyButton.setTitle("$\(price)", forState: .Normal)
            }
        }
    }
    
    let imageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .ScaleAspectFill
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Details", "Reviews", "Related"])
        sc.tintColor = UIColor.darkGrayColor()
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "TEST"
        label.font = UIFont.systemFontOfSize(16)
        return label
    }()
    
    let buyButton: UIButton = {
        let button = UIButton(type: .System)
        button.setTitle("BUY", forState: .Normal)
        button.layer.borderColor = UIColor(red: 0, green: 129/255, blue: 250/255, alpha: 1).CGColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        return button
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addSubview(segmentedControl)
        addSubview(nameLabel)
        addSubview(buyButton)
        addSubview(dividerView)
        
        addConstraintsWithFormat("H:|-14-[v0(100)]-8-[v1]|", views: imageView, nameLabel)
        addConstraintsWithFormat("V:|-14-[v0(100)]", views: imageView)
        
        addConstraintsWithFormat("V:|-14-[v0(20)]", views: nameLabel)
        
        addConstraintsWithFormat("H:|-40-[v0]-40-|", views: segmentedControl)
        addConstraintsWithFormat("V:[v0(34)]-8-|", views: segmentedControl)
        
        addConstraintsWithFormat("H:[v0(60)]-14-|", views: buyButton)
        addConstraintsWithFormat("V:[v0(32)]-56-|", views: buyButton)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerView)
        addConstraintsWithFormat("V:[v0(0.5)]|", views: dividerView)
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        
        for(index, view) in views.enumerate() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
}