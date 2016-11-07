//
//  SkinCenterCell.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/29.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import RxSwift

class SkinCenterCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curUsingFlag: UIImageView!
    
    @IBOutlet weak var deleteButton: UIButton!
    public weak var delete: ReplaySubject<ThemeInfo>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.addObserver(self, forKeyPath: "image", options: .initial, context: nil)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        layoutIfNeeded()
        
        if !hasAddShadow && imageView.image != nil {
            addShadow()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposebag = nil
    }
    
    deinit {
        imageView.removeObserver(self, forKeyPath: "image")
    }
    
   /* var layoutCount = 0
    override func layoutSubviews() {
        if !hasAddShadow {
            layoutCount += 1
            if layoutCount >= 2 && imageView.image != nil {
                addShadow()
            }
        }
        super.layoutSubviews()
    }*/

    private var themeInfo: ThemeInfo?
    func setInfo(_ info:ThemeInfo) {
        themeInfo = info
        configUI()
    }
    
    private var disposebag: DisposeBag?
    func configUI() {
        if let themeInfo = themeInfo {
            titleLabel.text = themeInfo.title
            imageView.tm_thumb_setImage(with: URL(string:themeInfo.thumb), placeholderImage: nil)
            
            disposebag = DisposeBag()
            ThemeManager.shareInstance.isCurrentTheme(withId: themeInfo.themeid).subscribe(onNext: {[weak weakSelf = self] isCurrentTheme in
                weakSelf?.curUsingFlag.isHidden = !isCurrentTheme
            }).addDisposableTo(disposebag!)
            
            if let delete = delete {
                deleteButton.isHidden = false
                deleteButton.rx.tap.withLatestFrom(Observable.just(themeInfo)).bindTo(delete).addDisposableTo(disposebag!)
            } else {
                deleteButton.isHidden = true
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "image" {
            if let image = object as? UIImageView {
                if (image.window != nil) {
                    addShadow()
                }
            }
        }
    }
    
    var hasAddShadow = false
    func addShadow() {
        if !hasAddShadow {
            imageView.layer.shadowOpacity = 0.6
            imageView.layer.shadowColor = UIColor.black.cgColor
            imageView.layer.shadowRadius = 3
            imageView.layer.shadowPath = UIBezierPath(rect: imageView.bounds.offsetBy(dx: 3, dy: 5)).cgPath
            
            curUsingFlag.layer.shadowOpacity = 0.6
            curUsingFlag.layer.shadowColor = UIColor.black.cgColor
            curUsingFlag.layer.shadowRadius = 3
            curUsingFlag.layer.shadowPath = UIBezierPath(ovalIn: curUsingFlag.bounds.offsetBy(dx: 3, dy: 5)).cgPath
            
            deleteButton.layer.shadowOpacity = 0.6
            deleteButton.layer.shadowColor = UIColor.black.cgColor
            deleteButton.layer.shadowRadius = 3
            deleteButton.layer.shadowPath = UIBezierPath(ovalIn: curUsingFlag.bounds.offsetBy(dx: 3, dy: 5)).cgPath
        }
        hasAddShadow = true
    }
}
