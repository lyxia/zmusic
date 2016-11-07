//
//  Observable+Netwoking.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/30.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation

import RxSwift
import Argo
import Moya

enum ORMError : Swift.Error {
    case ORMNoRepresentor
    case ORMNotSuccessfulHTTP
    case ORMNoData
    case ORMCouldNotMakeObjectError
}

extension Observable where Element:Moya.Response {
    
    private func resultFromJSON<T: Decodable>(object:[String: AnyObject], classType: T.Type) -> T? {
        let decoded = classType.decode(JSON(object))
        switch decoded {
        case .success(let result):
            return result as? T
        case .failure(let error):
            print(error)
            return nil
        }
    }
    
    // Returns a curried function that maps the object passed through
    // the observable chain into a class that conforms to Decodable
    func mapSuccessfulHTTPToObject<T: Decodable>(type: T.Type) -> Observable<T> {
        return map { representor in
            let response = representor
            
            // Allow successful HTTP codes
            guard ((200...209) ~= response.statusCode) else {
                if let json = try? response.mapJSON() as? [String: AnyObject] {
                    print("Got error message: \(json)")
                }
                throw ORMError.ORMNotSuccessfulHTTP
            }
            
            do {
                guard let json = self.getInfo(json: try! response.mapJSON()) as? [String: AnyObject] else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }
                return self.resultFromJSON(object: json, classType:type)!
            } catch {
                throw ORMError.ORMCouldNotMakeObjectError
            }
        }
    }
    
    // Returns a curried function that maps the object passed through
    // the observable chain into a class that conforms to Decodable
    func mapSuccessfulHTTPToObjectArray<T: Decodable>(type: T.Type) -> Observable<[T]> {
        return map { response in
            
            // Allow successful HTTP codes
            guard ((200...209) ~= response.statusCode) else {
                if let json = try? response.mapJSON() as? [String: AnyObject] {
                    print("Got error message: \(json)")
                }
                throw ORMError.ORMNotSuccessfulHTTP
            }
            
            do {
                guard let json = self.getInfo(json: try! response.mapJSON()) as? [[String : AnyObject]] else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }
                // Objects are not guaranteed, thus cannot directly map.
                var objects = [T]()
                for dict in json {
                    if let obj = self.resultFromJSON(object: dict, classType:type) {
                        objects.append(obj)
                    }
                }
                return objects
                
            } catch {
                throw ORMError.ORMCouldNotMakeObjectError
            }
        }
    }
    
    func getInfo(json: Any) -> Any {
        let data = (json as! NSDictionary)["data"]
        let info = (data as! NSDictionary)["info"]!
        return info
    }
    
}
