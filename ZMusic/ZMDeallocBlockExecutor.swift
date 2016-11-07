//
//  ZMDeallocBlockExecutor.swift
//  ZMusic
//
//  Created by lyxia on 2016/11/3.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation

typealias DeallocBlock = ()->Void

class ZMDeallocBlockExecutor: NSObject {
    private var deallocBlock: DeallocBlock?
    
    init(withDeallocBlock block: @escaping DeallocBlock) {
        deallocBlock = block
        super.init()
    }
    
    deinit {
        deallocBlock!()
        deallocBlock = nil
    }
}
