//
//  UserDefaults+Extension.swift
//  ZMusicUtils
//
//  Created by lyxia on 2016/10/24.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation

public struct PreferenceName<Type>: RawRepresentable {
    public typealias RawValue = String
    
    public var rawValue: String
    
    public init?(rawValue: PreferenceName.RawValue) {
        self.rawValue = rawValue
    }
}

public extension UserDefaults {
    public subscript(key: PreferenceName<Bool>) -> Bool? {
        set {set(newValue, forKey: key.rawValue)}
        get {return bool(forKey: key.rawValue)}
    }
    
    public subscript(key: PreferenceName<Int>) -> Int? {
        set {set(newValue, forKey: key.rawValue)}
        get {return integer(forKey: key.rawValue)}
    }
    
    public subscript(key: PreferenceName<String>) -> String? {
        set {set(newValue, forKey: key.rawValue)}
        get {return string(forKey: key.rawValue)}
    }
    
    public subscript(key: PreferenceName<Any>) -> Any? {
        set {set(newValue, forKey: key.rawValue)}
        get {return value(forKey: key.rawValue)}
    }
}

public struct PreferenceNames {
    public static let themeid = PreferenceName<Int>(rawValue: "themeid")!
    public static let themeBundlePath = PreferenceName<String>(rawValue: "themeBundlePath")!
}
