//
//  SkinCenterViewModel.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/8.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SkinCenterViewModel {
    //output
    let collectionItems: BehaviorSubject<[ThemeInfo]> = BehaviorSubject(value: [])
    let netError: SharedSequence<DriverSharingStrategy, Void>
    let presentSkinDetailVC: SharedSequence<DriverSharingStrategy, ThemeInfo?>
    let pushSkinManagerVC: SharedSequence<DriverSharingStrategy, Void>
    let dismissNav: SharedSequence<DriverSharingStrategy, Void>
    let dispose: Disposable
    
    //input
    let fetchThemeList: PublishSubject<Void> = PublishSubject()
    let skinSelected: PublishSubject<IndexPath> = PublishSubject()
    let tapManagerButton: PublishSubject<Void> = PublishSubject()
    let tapTopBackButton: PublishSubject<Void> = PublishSubject()
    
    
    init() {
        let fetchResult = fetchThemeList.flatMapLatest{_ -> Observable<[ThemeInfo]> in
            KugoutIOSCDNProvider.request(.themeList).mapSuccessfulHTTPToObjectArray(type: ThemeInfo.self)
        }.shareReplay(1)
        
        dispose = fetchResult.multicast(collectionItems).connect()
        netError = fetchResult.map{_ in return true}.catchErrorJustReturn(false).filter{$0}.map{_ in return Void()}.asDriver(onErrorJustReturn: Void())
        
        presentSkinDetailVC = skinSelected.withLatestFrom(collectionItems){indexPath, themes -> ThemeInfo? in
            let option: ThemeInfo? = themes[indexPath.row]
            return option
        }.asDriver(onErrorJustReturn: nil)
        
        pushSkinManagerVC = tapManagerButton.asDriver(onErrorJustReturn: Void())
        
        dismissNav = tapTopBackButton.asDriver(onErrorJustReturn: Void())
    }
}
