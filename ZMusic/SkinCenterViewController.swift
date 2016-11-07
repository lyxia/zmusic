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
    
    //请求对象
    private var requestForThemeList: Observable<[ThemeInfo]>  = {
        KugoutIOSCDNProvider.request(.themeList)
            .mapSuccessfulHTTPToObjectArray(type: ThemeInfo.self)
    }()
    
    //collectionView数据观察者
    private let collectionItems: Variable<[ThemeInfo]> = Variable([])
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "皮肤中心"
        
        //配置UI
        configUI()
        
        //开始请求数据
        requestThemeList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageCollectionView.reloadData()
    }
    
    func showSkinManager(){
        let vc = SkinManagerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configUI() {
        self.cuzNavigationItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"top_back"), style: .plain, target: self, action: #selector(dismissNav))
        self.cuzNavigationItem?.rightBarButtonItem = UIBarButtonItem(title: "管理", style: .plain, target: self, action: #selector(showSkinManager))
        
        imageCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: getFlowLayoutWith(bounds: self.view.bounds))
        imageCollectionView.register(UINib(nibName: "SkinCenterCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Cell")
        imageCollectionView.backgroundColor = .white
        imageCollectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        self.view.addSubview(imageCollectionView)
        
        collectionItems.asObservable().bindTo(imageCollectionView.rx.items(cellIdentifier: "Cell")) {(index, data, cell) in
            let skinCell = cell as! SkinCenterCell
            skinCell.setInfo(data)
        }.addDisposableTo(disposeBag)
        
        imageCollectionView.rx.itemSelected
            .subscribe{ [weak weakSelf = self] event in
                switch event {
                case .next(let indexPath):
                    if let value = weakSelf?.collectionItems.value {
                        let themeInfo = value[indexPath.row]
                        let skinDetailVc = SkinDetailViewController()
                        skinDetailVc.themeInfo = themeInfo
                        let nav = UINavigationController(rootViewController: skinDetailVc)
                        weakSelf?.present(nav, animated: true, completion: nil)
                    }
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func dismissNav() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func requestThemeList() {
        _ = requestForThemeList.subscribe { [weak weakSelf = self](event) in
            switch event {
            case .next(let themes):
                //用获取的数据来更新collectionItems
                weakSelf?.collectionItems.value = themes
            case .error(_):
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "网络出现问题啦~")
                PKHUD.sharedHUD.hide(afterDelay: 2)
            case .completed:
                break
            }
            }.addDisposableTo(disposeBag)
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
