//
//  SkinManagerViewController.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/2.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import ZMusicUIFrame
import RxSwift
import RxCocoa
import PKHUD

class SkinManagerViewController: CuzNavigationContentController {

    private var imageCollectionView: UICollectionView!
    
    private var viewModel: SkinManagerViewModel!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "皮肤管理"
        
        viewModel = SkinManagerViewModel()
        
        configUI()
        fetchThemeList()
    }
    
    func fetchThemeList() {
        viewModel.fetchThemeList.onNext(Void())
    }
    
    deinit {
        print("SkinManagerViewController dealloc")
    }
    
    func configUI() {
        imageCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: getFlowLayoutWith(bounds: self.view.bounds))
        imageCollectionView.register(UINib(nibName: "SkinCenterCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Cell")
        imageCollectionView.backgroundColor = .white
        imageCollectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        self.view.addSubview(imageCollectionView)
        
        //数据绑定
        viewModel.collectionItems.asObservable().bindTo(imageCollectionView.rx.items(cellIdentifier: "Cell")) {[weak weakSelf = self](index, data, cell) in
            let skinCell = cell as! SkinCenterCell
            skinCell.delete = weakSelf?.viewModel.checkCurTheme
            skinCell.setInfo(data)
            }.addDisposableTo(disposeBag)
        
        //确定要删除当前正在使用的主题
        let sureDeleteCurrent = DefaultWireframe.sharedInstance.promptFor(title:nil, message:"正在使用这款皮肤，确定要删除吗？", cancelAction: "取消", actions: ["删除"]).filter{action in
            if action == "删除" {
                return true
            }
            return false
        }.asDriver(onErrorJustReturn: "")
        viewModel.showDeleteAlert.flatMapLatest { (_) -> SharedSequence<DriverSharingStrategy, String> in
            return sureDeleteCurrent
            }
            .drive(onNext: {[weak weakSelf = self] _ in
                weakSelf?.viewModel.alertsureButtonDidTap.onNext(Void())
            }).addDisposableTo(disposeBag)
        
        //开始设置默认主题
        viewModel.startSetDefaultTheme.drive(onNext: {_ in
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "正在设置默认主题...")
            PKHUD.sharedHUD.show()
        }).addDisposableTo(disposeBag)
        
        //设置完默认主题
        viewModel.didSetDefaultTheme.drive(onNext: {result in
            if !result {
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "默认主题设置失败")
                PKHUD.sharedHUD.hide(afterDelay: 2)
            }
        }).addDisposableTo(disposeBag)
        
        //开始删除主题
        viewModel.startDeleteTheme.drive(onNext: {_ in
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "正在删除主题...")
            PKHUD.sharedHUD.show()
        }).addDisposableTo(disposeBag)
        
        //删除完主题
        viewModel.didDeleteTheme.drive(onNext: {[weak weakSelf = self]result in
            if !result {
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "主题删除失败")
                PKHUD.sharedHUD.hide(afterDelay: 2)
            } else {
                weakSelf?.fetchThemeList()
                PKHUD.sharedHUD.hide()
            }
        }).addDisposableTo(disposeBag)
        
        //界面消失
        viewModel.dismissViewController.drive(onNext: {[weak weakSelf = self] _ in
            _ = weakSelf?.navigationController?.popViewController(animated: true)
        }).addDisposableTo(disposeBag)
        
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
