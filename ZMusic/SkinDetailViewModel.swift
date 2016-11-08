//
//  SkinDetailViewModel.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/8.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct SkinDetailViewModel {
    //output
    let images: Observable<[SectionModel<String, String>]>
    let dismissVC: SharedSequence<DriverSharingStrategy, Void>
    let btnStatus: SharedSequence<DriverSharingStrategy, (String, Bool)>
    let startChangeTheme: SharedSequence<DriverSharingStrategy, Void>
    let didChangeTheme: SharedSequence<DriverSharingStrategy, Bool>
    let startDownload: SharedSequence<DriverSharingStrategy, Void>
    let didDownload: SharedSequence<DriverSharingStrategy, Bool>
    let startSavaTheme: SharedSequence<DriverSharingStrategy, Void>
    let didSavaTheme: SharedSequence<DriverSharingStrategy, Bool>
    let numOfPage: Int
    let themeName: String
    let themeSize: String
    
    //input
    let tapBackButton: PublishSubject<Void> = PublishSubject()
    let tapThemeStatusBtn: PublishSubject<String> = PublishSubject()
    
    init(model: ThemeInfo) {
        images = Observable.just([SectionModel(model:"first section", items:model.preview)])
        
        dismissVC = tapBackButton.asDriver(onErrorJustReturn: Void())
        
        let isCurrentTheme = ThemeManager.shareInstance.isCurrentTheme(withId: model.themeid)
        let isLocalTheme = ThemeManager.shareInstance.isLocalTheme(withId: model.themeid)
        btnStatus = Observable.combineLatest(isCurrentTheme, isLocalTheme) {(isCurrent, localTheme) -> (String, Bool) in
            if isCurrent {
                if let localTheme = localTheme, localTheme.downloadPackage == model.downloadPackage{
                    return ("使用中",false)
                } else {
                    return ("更新",true)
                }
            } else {
                if let localTheme = localTheme, localTheme.downloadPackage == model.downloadPackage{
                    return ("使用",true)
                } else {
                    return ("下载",true)
                }
            }

            }.asDriver(onErrorJustReturn: ("", false))
        
        let downTheme = tapThemeStatusBtn.filter{title in title != "使用"}
        startDownload = downTheme.map{_ in Void()}.asDriver(onErrorJustReturn: Void())
        didDownload = downTheme.flatMapLatest{_ in
            ThemeManager.shareInstance.getRomoteBundle(romoteUrl: model.downloadPackage)
            }.map{_ in true}.asDriver(onErrorJustReturn: false)
        startSavaTheme = didDownload.filter{$0}.map{_ in Void()}
        didSavaTheme = startSavaTheme.asObservable().flatMapLatest{_ in
            ThemeManager.shareInstance.addThemeToLocal(theme: model)
        }.asDriver(onErrorJustReturn: false)
        
        let useTheme = tapThemeStatusBtn.filter{title in title == "使用"}.map{_ in true}.asDriver(onErrorJustReturn: false)
        let successSava = didSavaTheme.filter{$0}
        startChangeTheme = Observable.of(successSava, useTheme).merge().map{_ in Void()}.asDriver(onErrorJustReturn: Void())
        didChangeTheme = startChangeTheme.asObservable().flatMapLatest{_ in
            return ThemeManager.shareInstance.getRomoteBundle(romoteUrl: model.downloadPackage)
            }.flatMapLatest{ bundle -> Observable<Bool> in
                return ThemeManager.shareInstance.setThemeWith(id: model.themeid, bundle: bundle)
            }.asDriver(onErrorJustReturn: false)
        
        numOfPage = model.preview.count
        themeName = model.title
        themeSize = "\(Float(model.filesize) / (1024 * 1024))M"
    }
}
