//
//  KugouIOSCDNAPI.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/28.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import RxSwift
import Moya

let KugoutIOSCDNProvider = RxMoyaProvider<KugouIOSCDN>()

enum KugouIOSCDN {
    case themeList
}

extension KugouIOSCDN: TargetType {
    var baseURL: URL {return URL(string:"http://ioscdn.kugou.com")!}
    var path: String {
        switch self {
        case .themeList:
            return "/api/v3/theme/index"
        }
    }
    var method: Moya.Method {
        switch self {
        case .themeList:
            return .get
        }
    }
    var parameters: [String : Any]? {
        switch self {
        case .themeList:
            return ["plat": "2", "tversion":"1.5", "model": "iPhone"]
        }
    }
    var task: Task {
        switch self {
        case .themeList:
            return .request
        }
    }
    var sampleData: Data {
        switch self {
        case .themeList:
            return "a".data(using: String.Encoding.utf8)!
        }
    }
}


extension ObservableType where E:Moya.Response {
    func handlerResponseJson() -> Observable<Any> {
        let a = self.map { (response) -> Any in
            let json = try! response.mapJSON()
            let data = (json as! NSDictionary)["data"]
            let info = (data as! NSDictionary)["info"]!
            return info
        }
        return a
    }
}
