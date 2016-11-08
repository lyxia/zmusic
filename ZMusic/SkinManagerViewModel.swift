//
//  SkinManagerViewModel.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/7.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SkinManagerViewModel {
    //output
    let collectionItems: SharedSequence<DriverSharingStrategy, [ThemeInfo]>
    let showDeleteAlert: SharedSequence<DriverSharingStrategy, Void>
    let startSetDefaultTheme: SharedSequence<DriverSharingStrategy, Void>
    let didSetDefaultTheme: SharedSequence<DriverSharingStrategy, Bool>
    let startDeleteTheme: SharedSequence<DriverSharingStrategy, Void>
    let didDeleteTheme: SharedSequence<DriverSharingStrategy, Bool>
    let dismissViewController: SharedSequence<DriverSharingStrategy, Void>
    
    //input
    let fetchThemeList: PublishSubject<Void> = PublishSubject()
    let checkCurTheme: ReplaySubject<ThemeInfo> = ReplaySubject.create(bufferSize: 1)
    let alertsureButtonDidTap: PublishSubject<Void> = PublishSubject()
    
    init() {
        //output
        collectionItems = fetchThemeList.flatMapLatest {
            return ThemeManager.shareInstance.getLocalThemeDic()
            }.map{ themesDic -> [ThemeInfo] in
                let themes = themesDic.map{(_, themeInfo) -> ThemeInfo in
                    return themeInfo
                }
                return themes
            }.asDriver(onErrorJustReturn: [])
        
        let isCurrentTheme = checkCurTheme.asObservable().flatMapLatest{ (themeInfo) -> Observable<Bool> in
            return ThemeManager.shareInstance.isCurrentTheme(withId: themeInfo.themeid)
        }
        let currentTheme = isCurrentTheme.filter{$0}.map{_ in return Void()}
        let notCurrentTheme = isCurrentTheme.filter{!$0}.map{_ in return Void()}
        
        //如果删除当前主题，弹alert
        showDeleteAlert = currentTheme.asDriver(onErrorJustReturn: Void())
        //开始设置默认主题
        startSetDefaultTheme = alertsureButtonDidTap.asDriver(onErrorJustReturn: Void())
        //设置完默认主题
        let deleteCurrentTheme = alertsureButtonDidTap.withLatestFrom(checkCurTheme.asObservable())
        didSetDefaultTheme = deleteCurrentTheme.flatMapLatest{(themeInfo) in
            return ThemeManager.shareInstance.setThemeWith(id: ThemeManager.shareInstance.defaultThemeId, bundle: ThemeManager.shareInstance.defaultThemeBoundle)
        }.asDriver(onErrorJustReturn: false)
        
        //删除主题
        let deleteCurTheme = didSetDefaultTheme.asObservable().filter{$0}.map{_ in return Void()}.withLatestFrom(checkCurTheme.asObservable())
        let deleteTheme = notCurrentTheme.withLatestFrom(checkCurTheme.asObservable())
        let allDeleteItem = Observable.of(deleteCurTheme, deleteTheme).merge().shareReplay(1)
        //开始删除主题
        startDeleteTheme = allDeleteItem.map{_ in return Void()}.asDriver(onErrorJustReturn: Void())
        //已经删除主题
        didDeleteTheme = allDeleteItem.asObservable()
            .flatMapLatest{(themeInfo) in
                return ThemeManager.shareInstance.removeThemeInLoacl(theme: themeInfo)
            }.asDriver(onErrorJustReturn: false)
        
        //移除界面
        dismissViewController = didDeleteTheme.asObservable().filter{$0}.withLatestFrom(currentTheme).asDriver(onErrorJustReturn: Void())
    }
    
}
