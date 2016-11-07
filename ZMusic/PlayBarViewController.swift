//
//  PlayBarViewController.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/4.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import ZMusicUIFrame

class PlayBarViewController: UITabBarController {
    
    var rotationTransition: CuzRotationPresentationController!
    var playVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add main vc
        let mainVC = CuzNavigationController(rootViewController: MainViewController())
        self.addChildViewController(mainVC)
        
        //tabbar 
        tabBar.nt_setBackgroundImage(UIImage.nt_imageNamed("playbar_bg"))
        
        //tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tabBar.addGestureRecognizer(tap)
        
        //desVC
        let desVC = PlayViewController()
        playVC = desVC
        
        //rotationTransition
        rotationTransition = CuzRotationPresentationController(presentedViewController: playVC, presenting: self)
        playVC.transitioningDelegate = rotationTransition
    }
    
    
    
    func tapHandler(_ gesture: UITapGestureRecognizer) {
        self.present(playVC, animated: true, completion: nil)
    }
    
    func dismissWithAnimal() {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
}

