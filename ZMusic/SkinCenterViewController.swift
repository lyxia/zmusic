//
//  SkinCenterViewController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/25.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import SnapKit
import ZMusicUIFrame
import PKHUD

class SkinCenterNavgationController: CuzNavigationController {
    
    var linePVC: CuzLinePresentationController?
    init(presentingVC: UIViewController) {
        super.init(rootViewController: SkinCenterViewController())
        
        linePVC = CuzLinePresentationController(presentedViewController: self, presenting: presentingVC)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        linePVC = nil
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("SkinCenterNavgationController dealloc")
    }
}

import ZMusicUtils
class SkinCenterViewController: CuzNavigationContentController {
    
    deinit {
        print("SkinCenterViewController dealloc")
    }
    
    private var imageCollectionView: UICollectionView!
    
    private var viewModel: SkinCenterViewModel!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "皮肤中心"
        
        //配置UI
        configUI()
        
        //配置viewmodel
        configViewModel()
        
        //开始请求数据
        requestThemeList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageCollectionView.reloadData()
    }
    
    func configUI() {
        //初始化imageCollectionView
        imageCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: getFlowLayoutWith(bounds: self.view.bounds))
        imageCollectionView.register(UINib(nibName: "SkinCenterCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Cell")
        imageCollectionView.backgroundColor = .white
        imageCollectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        self.view.addSubview(imageCollectionView)
        //设置navigationbar左右按钮
        self.cuzNavigationItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"top_back"), style: .plain, target: nil, action: nil)
        self.cuzNavigationItem?.rightBarButtonItem = UIBarButtonItem(title: "管理", style: .plain, target: nil, action: nil)
    }
    
    func configViewModel() {
        self.viewModel = SkinCenterViewModel()
        viewModel.dispose.addDisposableTo(disposeBag)
        
        //viewmodel input
        self.cuzNavigationItem?.leftBarButtonItem?.rx.tap.bindTo(viewModel.tapTopBackButton).addDisposableTo(disposeBag)
        self.cuzNavigationItem?.rightBarButtonItem?.rx.tap.bindTo(viewModel.tapManagerButton).addDisposableTo(disposeBag)
        imageCollectionView.rx.itemSelected.bindTo(viewModel.skinSelected).addDisposableTo(disposeBag)
        
        //viewmodel output
        viewModel.collectionItems.asObservable().bindTo(imageCollectionView.rx.items(cellIdentifier: "Cell")) {(index, data, cell) in
            let skinCell = cell as! SkinCenterCell
            skinCell.setInfo(data)
            }.addDisposableTo(disposeBag)
        viewModel.netError.drive(onNext: {_ in
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "网络出现问题啦~")
            PKHUD.sharedHUD.hide(afterDelay: 2)
        }).addDisposableTo(disposeBag)
        viewModel.presentSkinDetailVC.drive(onNext: { [weak weakSelf = self] themeInfo in
            if let themeInfo = themeInfo {
                let skinDetailVc = SkinDetailViewController(withModel: SkinDetailViewModel(model: themeInfo))
                let nav = UINavigationController(rootViewController: skinDetailVc)
                weakSelf?.present(nav, animated: true, completion: nil)
            }
        }).addDisposableTo(disposeBag)
        viewModel.pushSkinManagerVC.drive(onNext: {[weak weakSelf = self] _ in
            let vc = SkinManagerViewController()
            weakSelf?.navigationController?.pushViewController(vc, animated: true)
        }).addDisposableTo(disposeBag)
        viewModel.dismissNav.drive(onNext: {[weak weakSelf = self] _ in
            weakSelf?.navigationController?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
    
    func requestThemeList() {
        viewModel.fetchThemeList.onNext(Void())
    }
    
    struct FlowLayoutParams {
        static let EdgePading:CGFloat = 15
        static let Column:CGFloat = 3
        static let WHRatio:CGFloat = 16 / 9
    }
    func getFlowLayoutWith(bounds:CGRect) -> UICollectionViewFlowLayout {
        let contentWidth = bounds.maxX - FlowLayoutParams.EdgePading
        let itemWidth = contentWidth / FlowLayoutParams.Column
        let itemHeight = itemWidth * FlowLayoutParams.WHRatio
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, FlowLayoutParams.EdgePading, FlowLayoutParams.EdgePading, 0)
        return flowLayout
    }
}
