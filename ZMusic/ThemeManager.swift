//
//  ThemeManager.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/21.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit
import ZMusicUtils
import RxSwift
import SDWebImage

class ThemeManager {
    static let shareInstance = ThemeManager()
    
    fileprivate let themePreviewImageManager:SDWebImageManager = {
        var dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        dir.appendPathComponent("kugouTheme/cachePic")
        let imageCache = SDImageCache(namespace: "priview", diskCacheDirectory: dir.path)
        let downloader = SDWebImageDownloader.shared()
        let imageManager = SDWebImageManager(cache: imageCache, downloader: downloader)!
        return imageManager
    }()
    
    fileprivate let themeThumbImageManager:SDWebImageManager = {
        var dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        dir.appendPathComponent("kugouTheme/cachePic")
        let imageCache = SDImageCache(namespace: "thumb", diskCacheDirectory: dir.path)
        let downloader = SDWebImageDownloader.shared()
        let imageManager = SDWebImageManager(cache: imageCache, downloader: downloader)!
        return imageManager
    }()
    
    public let defaultThemeId = 0
    public let defaultThemeBoundle: Bundle = {
        let bundelPath = Bundle.main.path(forResource: "blue", ofType: "bundle")!
        return Bundle(path: bundelPath)!
    }()
    
    private init() {
        if let themeid = UserDefaults.standard[PreferenceNames.themeid],
            let themeBundlePath = UserDefaults.standard[PreferenceNames.themeBundlePath]{
            if let bundle = Bundle(path: themeBundlePath) {
                self.setThemeBlockRunloop(id: themeid, bundle: bundle)
            } else {
                self.setThemeBlockRunloop(id: defaultThemeId, bundle: defaultThemeBoundle)
            }
        } else {
            self.setThemeBlockRunloop(id: defaultThemeId, bundle: defaultThemeBoundle)
        }
    }
    private func setThemeBlockRunloop(id: Int, bundle: Bundle) {
        let configPath = bundle.path(forResource: "themeConfig", ofType: "json")!
        let url = URL(fileURLWithPath: configPath)
        let data = try! Data(contentsOf: url)
        let config = try! JSONSerialization.jsonObject(with: data, options:.mutableLeaves) as! NSDictionary
        curBundle = bundle
        curConfig = config
        UserDefaults.standard[PreferenceNames.themeid] = id
        UserDefaults.standard[PreferenceNames.themeBundlePath] = bundle.resourcePath
    }
    
    private var curBundle: Bundle!
    private var curConfig: NSDictionary!
    
    public func setThemeWith(id: Int, bundle: Bundle) -> Observable<Bool> {
        return Observable<NSDictionary>.create { (observer) -> Disposable in
            let configPath = bundle.path(forResource: "themeConfig", ofType: "json")!
            let url = URL(fileURLWithPath: configPath)
            do {
                let data = try Data(contentsOf: url)
                let config = try JSONSerialization.jsonObject(with: data, options:.mutableLeaves) as! NSDictionary
                observer.onNext(config)
                observer.onCompleted()
            } catch (let error) {
                observer.onError(error)
            }
            return Disposables.create()
            }
            .subscribeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            .observeOn(Dependencies.sharedDependencies.mainScheduler).map { [weak weakSelf = self](config) -> Bool in
                if let weakSelf = weakSelf {
                    UserDefaults.standard[PreferenceNames.themeid] = id
                    UserDefaults.standard[PreferenceNames.themeBundlePath] = bundle.resourcePath
                    weakSelf.curConfig = config
                    weakSelf.curBundle = bundle
                    NotificationCenter.default.post(name: ZMThemeChangeNotification.name, object: nil)
                }
                return true
        }
    }
    
    func getImage(byKey key: String) -> UIImage? {
        let imagesInfo = curConfig["imageType"] as! NSArray
        let filters = imagesInfo.filter { (image) -> Bool in
            let dic = image as! NSDictionary
            return (dic["key"] as! NSString) as String == key
        }
        if filters.count > 0 {
            let imageInfo = filters.first as! NSDictionary
            let imageName = imageInfo["image"] as! String
            
            let imagePath = curBundle.resourcePath! + "/" + imageName
            return UIImage(contentsOfFile: imagePath)
            //return UIImage(contentsOfFile: imagePath) ?? UIImage(contentsOfFile:defaultThemeBoundle.resourcePath! + "/" + imageName)
        }
        return nil
    }
    
    func getHighlightedImage(byKey key: String) -> UIImage? {
        let imagesInfo = curConfig["imageType"] as! NSArray
        let filters = imagesInfo.filter { (image) -> Bool in
            let dic = image as! NSDictionary
            return (dic["key"] as! NSString) as String == key
        }
        if filters.count > 0 {
            let imageInfo = filters.first as! NSDictionary
            let imageName = imageInfo["highlighted_image"] as! String
            let imagePath = curBundle.resourcePath! + "/" + imageName
            return UIImage(contentsOfFile: imagePath)
            //return UIImage(contentsOfFile: imagePath) ?? UIImage(contentsOfFile:defaultThemeBoundle.resourcePath! + "/" + imageName)
        }
        return nil
    }
    
    func getColor(byKey key: String) -> UIColor? {
        let colorsInfo = curConfig["colorType"] as! NSArray
        let filters = colorsInfo.filter { (color) -> Bool in
            let dic = color as! NSDictionary
            return (dic["key"] as! String) == key
        }
        if let colorInfo = filters.first as? NSDictionary {
            let color = colorInfo["color"] as! String
            if let alpha = colorInfo["alpha"] as? CGFloat {
                UIColor.hexStringToColor(hexString: color).withAlphaComponent(alpha)
            }
            return UIColor.hexStringToColor(hexString: color)
        }
        return nil
    }
    
    func getBool(byKey key:String) -> Bool {
        let boolsInfo = curConfig["boolType"] as! NSArray
        let filters = boolsInfo.filter { (bool) -> Bool in
            let dic = bool as! NSDictionary
            return (dic["key"] as! String) == key
        }
        if let boolInfo = filters.first as? NSDictionary {
            if (boolInfo["boolvalue"] as? String) == "1" {
                return true
            }
        }
        return false
    }
}

extension ThemeManager {
    func getRomoteBundle(romoteUrl:String) -> Observable<Bundle> {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        return ZipHelper.getBundle(zipUrl: romoteUrl, component: "kugouTheme/themePackage").subscribeOn(OperationQueueScheduler(operationQueue: operationQueue)).observeOn(MainScheduler.instance)
    }
}

enum ArchiveError: Swift.Error {
    case ArchiverError
}

extension ThemeManager {
    func addThemeToLocal(theme: ThemeInfo) -> Observable<Bool> {
        return getLocalThemeDic().flatMap { [weak weakSelf = self](themesDic) -> Observable<Bool> in
            var mutableDic = themesDic
            mutableDic[theme.themeid] = theme
            return weakSelf!.savaLocalThemeDic(themesDic: mutableDic)
        }
    }
    
    func removeThemeInLoacl(theme: ThemeInfo) -> Observable<Bool> {
        return getLocalThemeDic().flatMap { [weak weakSelf = self](themesDic) -> Observable<Bool> in
            if let theme = themesDic[theme.themeid] {
                var mutableDic = themesDic
                mutableDic.removeValue(forKey: theme.themeid)
                return weakSelf!.savaLocalThemeDic(themesDic: mutableDic)
            }
            return Observable.just(false)
        }.do(onNext: { (result) in
            if result {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileNameWithSuffix = URL(string: theme.downloadPackage)!.lastPathComponent
                    let fileName = fileNameWithSuffix.substring(to: fileNameWithSuffix.index(fileNameWithSuffix.endIndex, offsetBy: -4))
                    var fileUrl = dir
                    fileUrl.appendPathComponent("kugouTheme/themePackage/" + fileName)
                    try? FileManager.default.removeItem(at: fileUrl)
                }
            }
        })
    }
    
    func isCurrentTheme(withId id: Int) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            let curTheme = UserDefaults.standard[PreferenceNames.themeid]
            if id == curTheme {
                observer.onNext(true)
            } else {
                observer.onNext(false)
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func isLocalTheme(withId id:Int) -> Observable<ThemeInfo?> {
        return getLocalThemeDic().map { (themesDic) -> ThemeInfo? in
            return themesDic[id]
        }
    }
    
    func getLocalThemeDic() -> Observable<Dictionary<Int, ThemeInfo>> {
        return getLocalThemeUrl().map { (url) -> Dictionary<Int, ThemeInfo> in
            do {
                let data = try Data(contentsOf: url)
                if let themesDic = NSKeyedUnarchiver.unarchiveObject(with: data) as? Dictionary<Int, ThemeInfo> {
                    return themesDic
                } else {
                    return [:]
                }
            } catch {
                return [:]
            }
        }
    }
    
    func savaLocalThemeDic(themesDic: Dictionary<Int, ThemeInfo>) -> Observable<Bool> {
        return getLocalThemeUrl().map { (url) -> Bool in
            if NSKeyedArchiver.archiveRootObject(themesDic, toFile: url.path) {
                return true
            }
            throw ArchiveError.ArchiverError
        }
    }
    
    func getLocalThemeUrl() -> Observable<URL> {
        return ZipHelper.getUserDocumentDirectory().map { (url) -> URL in
            return url.appendingPathComponent("kugouTheme" + "/" + "themesDic.plist")
        }
    }
}


extension UIImageView {
    func tm_preview_setImage(with url: URL!, placeholderImage placeholder:UIImage?) {
        
        tm_setImage(with: ThemeManager.shareInstance.themePreviewImageManager, url: url, placeholderImage: placeholder)
    }
    func tm_thumb_setImage(with url: URL!, placeholderImage placeholder:UIImage?) {
        
        tm_setImage(with: ThemeManager.shareInstance.themeThumbImageManager, url: url, placeholderImage: placeholder)
    }
    
    func tm_setImage(with manager:SDWebImageManager, url: URL!, placeholderImage placeholder:UIImage?) {
        self.image = placeholder
        
        let operation = manager.downloadImage(with: url, options: .retryFailed, progress: nil){[weak weakSelf=self](image, error, cacheType, finished, imageUrl) in
            if let weakSelf = weakSelf {
                if let image = image {
                    weakSelf.image = image
                } else {
                    weakSelf.image = placeholder
                }
                self.setNeedsLayout()
            }
        }
        
        self.sd_setImageLoadOperation(operation, forKey: "UIImageViewImageLoad")
    }
}
