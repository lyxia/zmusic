//
//  MainViewController.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/22.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import SnapKit
import ZMusicUIFrame

class MainViewController: CuzNavigationContentController {
    
    init() {
        super.init(nibName: "MainViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var listenLibrayBtn: UIButton!
    @IBOutlet weak var listenRadioBtn: UIButton!
    @IBOutlet weak var listenGroupBtn: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var musicListBtn: UIButton!
    @IBOutlet weak var downBtn: UIButton!
    @IBOutlet weak var recentBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    private var drawer: SideBarPresentationController!
    private var sideBar: SideBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //配置界面
        configUI()
    }
    
    func configUI() {
        //配置抽屉
        sideBar = SideBarViewController()
        drawer = SideBarPresentationController(presentedViewController: sideBar, presenting: self)
        
        //配置按钮样式
        likeBtn.updatePosition(withStyle: .ImageUpTitle, spacing: 5)
        musicListBtn.updatePosition(withStyle: .ImageUpTitle, spacing: 5)
        downBtn.updatePosition(withStyle: .ImageUpTitle, spacing: 5)
        recentBtn.updatePosition(withStyle: .ImageUpTitle, spacing: 5)
        listenGroupBtn.updatePosition(withStyle: .ImageUpTitle, spacing: 5)
        listenRadioBtn.updatePosition(withStyle: .ImageUpTitle, spacing: 5)
        listenLibrayBtn.updatePosition(withStyle: .ImageUpTitle, spacing: 5)
        
        //设置背景图
        bgImageView.nt_image = UIImage.nt_imageNamed("home_listen_bg_one")
        
        //设置导航栏背景图
        self.cuzNavigationBar?.nt_setBackgroundImage(UIImage.nt_imageNamed("home_top_bg"))
        
        //添加导航栏左边按钮
        let userctBtn = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
        userctBtn.nt_setImage("userct")
        userctBtn.addTarget(self, action: #selector(showSidebar(_:)), for: .touchUpInside)
        if let item = self.cuzNavigationItem {
            item.leftBarButtonItem = UIBarButtonItem(customView: userctBtn)
        }
        
        //按钮样式
        likeBtn.nt_setImage("listen_like")
        musicListBtn.nt_setImage("listen_musiclist")
        downBtn.nt_setImage("listen_download")
        recentBtn.nt_setImage("listen_recent_play")
        listenLibrayBtn.nt_setImage("listen_library")
        listenRadioBtn.nt_setImage("listen_radio")
        listenGroupBtn.nt_setImage("listen_group")
        
        //分界线样式
        lineView.nt_setBackgroundImage(UIImage.nt_imageNamed("listen_separation_line"))
        
        //contentView背景图
        contentView.nt_setBackgroundImage(UIImage.nt_imageNamed("bg_content"))
        
        //添加手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
        self.view.addGestureRecognizer(pan)
    }
    
    func panHandler(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            if gesture.velocity(in: self.view).x > 0 {
                drawer.targetEdge = .right
            } else {
                drawer.targetEdge = .left
            }
        }
        drawer.presentGestureHandler(gesture: gesture)
    }
    
    func showSidebar(_ sender:UIButton) {
        drawer.targetEdge = .right
        self.present(sideBar, animated: true, completion: nil)
    }
}

