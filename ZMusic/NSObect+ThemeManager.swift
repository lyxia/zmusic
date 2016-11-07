//
//  NSObect+ThemeManager.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/3.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation

struct ZMThemeChangeNotification {
    static let name = NSNotification.Name("ZMThemeChangeNotification")
}

fileprivate struct AssociatedKeys {
    static var pickersKey: UInt8 = 0
    static var deallocBlockKey: UInt8 = 1
    static var test: UInt8 = 2
}

typealias MEPicker = ()->AnyObject?

class PickerClosureWrapper {
    var closure: MEPicker?
    
    init(_ closure: MEPicker?) {
        self.closure = closure
    }
}

extension NSObject {
    
    var pickers: NSMutableDictionary {
        get {
            var pickers = objc_getAssociatedObject(self, &AssociatedKeys.pickersKey) as? NSMutableDictionary
            if pickers == nil {
                pickers = NSMutableDictionary()
                objc_setAssociatedObject(self, &AssociatedKeys.pickersKey, pickers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                //初始化的时候添加通知
                let observer = NotificationCenter.default.addObserver(forName: ZMThemeChangeNotification.name, object: nil, queue: nil, using: { [weak weakSelf = self] (_) in
                    weakSelf?.changeTheme()
                })
                //dealloc时移除通知
                if getDeallocHelperExecutor() == nil {
                    let deallocBlockExecutor = ZMDeallocBlockExecutor{NotificationCenter.default.removeObserver(observer)}
                    setDeallocHelperExecutor(deallocBlockExecutor: deallocBlockExecutor)
                }
            }
            return pickers!
        }
    }
    
    func changeTheme() {
        _ = self.pickers.map { (key, wrapValue) in
            if let key = key as? String, let wrap = wrapValue as? PickerClosureWrapper, let value = wrap.closure {
                let sel = NSSelectorFromString(key)
                let obj = value()
                if self.responds(to: sel) {
                    self.perform(sel, with: obj)
                }
            }
        }
    }
}

extension NSObject {
    
    func getDeallocHelperExecutor() -> ZMDeallocBlockExecutor? {
        return objc_getAssociatedObject(self, &AssociatedKeys.deallocBlockKey) as? ZMDeallocBlockExecutor
    }
    
    func setDeallocHelperExecutor(deallocBlockExecutor: ZMDeallocBlockExecutor) {
        objc_setAssociatedObject(self, &AssociatedKeys.deallocBlockKey, deallocBlockExecutor, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
