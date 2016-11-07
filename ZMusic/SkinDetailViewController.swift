//
//  SkinDetailViewController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/30.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import ZMusicUIFrame
import RxSwift
import RxDataSources
import SDWebImage
import ZMusicUtils
import PKHUD

class SkinDetailViewController: UIViewController {

    var themeInfo: ThemeInfo?
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
            imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
            imageCollectionView.decelerationRate = 0.5
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var themeNameLabel: UILabel!
    @IBOutlet weak var themeSizeLabel: UILabel!
    @IBOutlet weak var themeStatusBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
        self.navigationController?.navigationBar.subviews.first?.alpha = 0
        self.title = "皮肤详情"

        configUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageCollectionView.collectionViewLayout = getImageCollectionLayout(withBound: imageCollectionView.bounds)
        imageCollectionView.contentOffset = CGPoint(x:imageCollectionView.contentSize.width/2 - imageCollectionView.bounds.width/2,y:0)
    }
    
    func configUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"backActionIcon"), style: .plain, target: self, action: #selector(closeHandler))
        
        if let themeInfo = self.themeInfo {
            let items = Observable.just([SectionModel(model:"first section", items:themeInfo.preview)])
            let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>()
            dataSource.configureCell = {[weak weakSelf = self] (dataSource, cv, indexPath, element) in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                if let imageView = cell.viewWithTag(10001) as? UIImageView {
                    imageView.tm_preview_setImage(with: URL(string: element), placeholderImage: UIImage())
                } else {
                    if let weakSelf = weakSelf {
                        let imageView = weakSelf.getImageView(withUrl: element)
                        cell.contentView.addSubview(imageView)
                        imageView.tag = 10001
                        imageView.snp.makeConstraints({ (make) in
                            make.edges.equalTo(cell.contentView)
                        })
                    }
                }
                return cell
            }
            items.bindTo(imageCollectionView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)
            
            pageControl.numberOfPages = themeInfo.preview.count
            imageCollectionView.rx.contentOffset.subscribe({ [weak weakSelf = self] (event) in
                switch event {
                case .next(let contentOffset):
                        if let weakSelf = weakSelf {
                            let percent = (contentOffset.x + weakSelf.imageCollectionView!.bounds.width/2) / weakSelf.imageCollectionView!.contentSize.width
                            if percent < 1 {
                                let page = Int(percent * CGFloat(weakSelf.themeInfo!.preview.count))
                                weakSelf.pageControl.currentPage = page
                            }
                        }
                default:
                    break
                }
            }).addDisposableTo(disposeBag)
            
            themeNameLabel.text = themeInfo.title
            themeSizeLabel.text = "\(Float(themeInfo.filesize) / (1024 * 1024))M"
            changeBtnStatus()
        }
    }
    
    @IBAction func themeStatusBtnClickHandler(_ sender: UIButton) {
        if sender.currentTitle == "使用" {
            useHandler()
        } else {
            downHandler()
        }
    }
    
    func changeBtnStatus() {
        let isCurrentTheme = ThemeManager.shareInstance.isCurrentTheme(withId: themeInfo!.themeid)
        let isLocalTheme = ThemeManager.shareInstance.isLocalTheme(withId: themeInfo!.themeid)
        Observable.combineLatest(isCurrentTheme, isLocalTheme) {(o1, o2) in
            return (o1, o2)
        }.subscribe { [weak weakSelf = self] (event) in
            switch event {
            case .next(let (isCurrent, localTheme)):
                if isCurrent {
                    if let localTheme = localTheme, localTheme.downloadPackage == weakSelf?.themeInfo!.downloadPackage{
                        weakSelf!.themeStatusBtn.isEnabled = false
                        weakSelf!.themeStatusBtn.setTitle("使用中", for: .disabled)
                    } else {
                        weakSelf!.themeStatusBtn.isEnabled = true
                        weakSelf!.themeStatusBtn.setTitle("更新", for: .normal)
                    }
                } else {
                    if let localTheme = localTheme, localTheme.downloadPackage == weakSelf?.themeInfo!.downloadPackage{
                        weakSelf!.themeStatusBtn.isEnabled = true
                        weakSelf!.themeStatusBtn.setTitle("使用", for: .normal)
                    } else {
                        weakSelf!.themeStatusBtn.isEnabled = true
                        weakSelf!.themeStatusBtn.setTitle("下载", for: .normal)
                    }
                }
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    //使用
    func useHandler() {
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: "正在切换皮肤...")
        
        let themeInfo = self.themeInfo!
        ThemeManager.shareInstance.getRomoteBundle(romoteUrl: themeInfo.downloadPackage)
            .flatMap { (bundle) -> Observable<Bool> in
            return ThemeManager.shareInstance.setThemeWith(id: themeInfo.themeid, bundle: bundle)
        }.subscribe { [weak weakSelf = self](event) in
            switch event {
            case .next(_):
                PKHUD.sharedHUD.hide()
                weakSelf!.dismiss(animated: true, completion: nil)
            case .error(let error):
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "皮肤切换失败")
                PKHUD.sharedHUD.hide(afterDelay: 2)
                print("\(error)")
            case .completed:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    //更新和下载
    func downHandler() {
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: "正在下载...")
        PKHUD.sharedHUD.show()
        
        let themeInfo = self.themeInfo!
        ThemeManager.shareInstance.getRomoteBundle(romoteUrl: themeInfo.downloadPackage)
            .flatMap {(bundle) -> Observable<Bool> in
                print("正在切换皮肤...\(Thread.current)")
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "正在切换皮肤...")
                return ThemeManager.shareInstance.setThemeWith(id: themeInfo.themeid, bundle: bundle)
            }.flatMap({_ -> Observable<Bool> in
                print("正在保存皮肤数据...")
                return ThemeManager.shareInstance.addThemeToLocal(theme: themeInfo)
            }).subscribe { [weak weakSelf = self](event) in
                print("皮肤切换完成-----\(Thread.current)")
                switch event {
                case .next(_):
                    PKHUD.sharedHUD.hide()
                    weakSelf!.dismiss(animated: true, completion: nil)
                case .error(let error):
                    var errMsg = "皮肤切换失败"
                    if let zipError = error as? ZIPError {
                        switch zipError {
                        case .ZIPErrorDownload:
                            errMsg = "皮肤下载失败"
                        default:
                            break
                        }
                    }
                    PKHUD.sharedHUD.contentView = PKHUDTextView(text: errMsg)
                    PKHUD.sharedHUD.hide(afterDelay: 2)
                case .completed:
                    break
                }
            }.addDisposableTo(disposeBag)
    }
    
    func closeHandler() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getImageView(withUrl url: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tm_preview_setImage(with: URL(string: url), placeholderImage: UIImage())
        return imageView
    }
    
    struct ImageLayoutParams {
        static let HWRadio:CGFloat = 9 / 16
        static let Padding:CGFloat = 70
        static let HeightRadio:CGFloat = 0.6
    }
    func getImageCollectionLayout(withBound bound: CGRect) -> LineScaleLayout {
        let layout = LineScaleLayout()
        let height = bound.size.height * ImageLayoutParams.HeightRadio
        let width = height * ImageLayoutParams.HWRadio
        let zoomFactor = (1 / ImageLayoutParams.HeightRadio) - 1
        layout.itemSize = CGSize(width: width, height:height)
        layout.minimumLineSpacing = ImageLayoutParams.Padding
        layout.zoomFactor = zoomFactor
        layout.activeDistance = 200
        return layout
    }

}
