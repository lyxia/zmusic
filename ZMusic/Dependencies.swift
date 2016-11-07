//
//  Dependencies.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/2.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif

class Dependencies {
    
    // *****************************************************************************************
    // !!! This is defined for simplicity sake, using singletons isn't advised               !!!
    // !!! This is just a simple way to move services to one location so you can see Rx code !!!
    // *****************************************************************************************
    static let sharedDependencies = Dependencies() // Singleton
    
    let URLSession = Foundation.URLSession.shared
    let backgroundWorkScheduler: ImmediateSchedulerType
    let mainScheduler: SerialDispatchQueueScheduler
    let wireframe: Wireframe
    let reachabilityService: ReachabilityService
    
    private init() {
        wireframe = DefaultWireframe()
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        #if !RX_NO_MODULE
            operationQueue.qualityOfService = QualityOfService.userInitiated
        #endif
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        
        mainScheduler = MainScheduler.instance
        reachabilityService = try! DefaultReachabilityService() // try! is only for simplicity sake
    }
    
}
