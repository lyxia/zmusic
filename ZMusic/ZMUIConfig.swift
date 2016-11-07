//
//  ZMUIConfig.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/4.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import ZMusicUIFrame
import UIKit

class ZMUIConfig: NSObject {
    static var uiconfig: ZMUIConfig?
    
    override static func initialize() {
        //创建自己
        uiconfig = ZMUIConfig()
        
        //只会执行一次
        uiconfig!.nt_setNavigationBarTine(UIColor.nt_colorPickerForId("title"))
        uiconfig!.nt_setNavigationItemTine(UIColor.nt_colorPickerForId("pnt"))
    }
    
    //获得UINavigation item主题样式
    func setNavigationItemTine(_ color:UIColor) {
        let appearance = UIBarButtonItem.appearance()
        appearance.setTitleTextAttributes([NSForegroundColorAttributeName:color], for: .normal)
        appearance.setTitleTextAttributes([NSForegroundColorAttributeName:color], for: .highlighted)
        UINavigationBar.appearance().tintColor = color
        CuzNavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: color]
    }
    
    //获得UINavigation bar主题样式
    func setNavigationBarTine(_ color:UIColor) {
        CuzNavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(color), for: .topAttached, barMetrics: .default)
        
    }
    
    static func setupUIConfig() {
        
    }
}

extension ZMUIConfig {
    func nt_setNavigationItemTine(_ colorPicker: @escaping ColorPicker) {
        self.setNavigationItemTine(colorPicker() ?? .white)
        self.pickers.setObject(PickerClosureWrapper(colorPicker), forKey: NSString(string:"setNavigationItemTine:"))
    }
    
    func nt_setNavigationBarTine(_ colorPicker: @escaping ColorPicker) {
        self.setNavigationBarTine(colorPicker() ?? UIColor.blue)
        self.pickers.setObject(PickerClosureWrapper(colorPicker), forKey: NSString(string:"setNavigationBarTine:"))
    }
    
    override func changeTheme() {
        super.changeTheme()
    }
}

