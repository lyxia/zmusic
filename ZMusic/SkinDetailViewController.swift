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
    
    private let viewModel: SkinDetailViewModel
    init(withModel model:SkinDetailViewModel) {
        viewModel = model
        super.init(nibName:"SkinDetailViewController", bundle:Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        configViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageCollectionView.collectionViewLayout = getImageCollectionLayout(withBound: imageCollectionView.bounds)
        imageCollectionView.contentOffset = CGPoint(x:imageCollectionView.contentSize.width/2 - imageCollectionView.bounds.width/2,y:0)
    }
    
    func configViewModel() {
        //input
        self.navigationItem.leftBarButtonItem?.rx.tap.bindTo(viewModel.tapBackButton).addDisposableTo(disposeBag)
        let title = Observable.deferred({[weak weakSelf = self] in Observable.just(weakSelf?.themeStatusBtn.titleLabel?.text)})
        self.themeStatusBtn.rx.tap.withLatestFrom(title)
            .filter{s in
                switch s {
                case .some(_):
                    return true
                case .none:
                    return false
                }
            }.map{$0!}.bindTo(viewModel.tapThemeStatusBtn).addDisposableTo(disposeBag)
        //output
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
        viewModel.images.bindTo(imageCollectionView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        viewModel.dismissVC.drive(onNext: {[weak weakSelf = self] _ in
            weakSelf?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        viewModel.btnStatus.drive(onNext: {[weak weakSelf = self](title, enable) in
            if enable {
                weakSelf?.themeStatusBtn.setTitle(title, for: .normal)
            } else {
                weakSelf?.themeStatusBtn.setTitle(title, for: .disabled)
            }
            weakSelf?.themeStatusBtn.isEnabled = enable
        }).addDisposableTo(disposeBag)
        viewModel.startChangeTheme.drive(onNext: {_ in
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "正在切换皮肤...")
            PKHUD.sharedHUD.show()
        }).addDisposableTo(disposeBag)
        viewModel.didChangeTheme.drive(onNext: {[weak weakSelf = self] _ in
            PKHUD.sharedHUD.hide()
            weakSelf?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        viewModel.startDownload.drive(onNext: {_ in
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "正在下载...")
            PKHUD.sharedHUD.show()
        }).addDisposableTo(disposeBag)
        viewModel.didDownload.drive(onNext: {result in
            if !result {
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "下载皮肤包失败")
                PKHUD.sharedHUD.hide(afterDelay: 2)
            }
        }).addDisposableTo(disposeBag)
        viewModel.startSavaTheme.drive(onNext: {_ in
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "正在保存皮肤数据...")
            PKHUD.sharedHUD.show()
        }).addDisposableTo(disposeBag)
        viewModel.didSavaTheme.drive(onNext: {result in
            if !result {
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "皮肤保存失败")
                PKHUD.sharedHUD.hide(afterDelay: 2)
            }
        }).addDisposableTo(disposeBag)
        pageControl.numberOfPages = viewModel.numOfPage
        themeNameLabel.text = viewModel.themeName
        themeSizeLabel.text = viewModel.themeSize
    }
    
    func configUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"backActionIcon"), style: .plain, target: nil, action: nil)
        
        imageCollectionView.rx.contentOffset.subscribe({ [weak weakSelf = self] (event) in
            switch event {
            case .next(let contentOffset):
                if let weakSelf = weakSelf {
                    let percent = (contentOffset.x + weakSelf.imageCollectionView!.bounds.width/2) / weakSelf.imageCollectionView!.contentSize.width
                    if percent < 1 {
                        let page = Int(percent * CGFloat(weakSelf.viewModel.numOfPage))
                        weakSelf.pageControl.currentPage = page
                    }
                }
            default:
                break
            }
        }).addDisposableTo(disposeBag)
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
