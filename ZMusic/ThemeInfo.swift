//
//  ThemeInfo.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/30.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

class ThemeInfo: NSObject, NSCoding {
    let id: Int
    let themeid: Int
    let version: String
    let title: String
    let privilege: Int
    let downloadPackage: String
    let filesize: Int64
    let thumb: String
    let preview: [String]
    
    static func getDefaultThemeInfo() -> ThemeInfo{
        return ThemeInfo(id: 0, themeid: 0, version: "", title: "", privilege: 0, downloadPackage: "", filesize: 0, thumb: "", preview: [])
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeInteger(forKey: "id")
        themeid = aDecoder.decodeInteger(forKey: "themeid")
        version = aDecoder.decodeObject(forKey: "version") as! String
        title = aDecoder.decodeObject(forKey: "title") as! String
        privilege = aDecoder.decodeInteger(forKey: "privilege")
        downloadPackage = aDecoder.decodeObject(forKey: "downloadPackage") as! String
        filesize = aDecoder.decodeInt64(forKey: "filesize")
        thumb = aDecoder.decodeObject(forKey: "thumb") as! String
        preview = aDecoder.decodeObject(forKey: "preview") as! [String]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(themeid, forKey: "themeid")
        aCoder.encode(version, forKey: "version")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(privilege, forKey: "privilege")
        aCoder.encode(downloadPackage, forKey: "downloadPackage")
        aCoder.encode(filesize, forKey: "filesize")
        aCoder.encode(thumb, forKey: "thumb")
        aCoder.encode(preview, forKey: "preview")
    }
    
    init(id: Int, themeid: Int, version: String, title: String, privilege: Int, downloadPackage: String, filesize: Int64, thumb: String, preview: [String]) {
        self.id = id
        self.themeid = themeid
        self.version = version
        self.title = title
        self.privilege = privilege
        self.downloadPackage = downloadPackage
        self.filesize = filesize
        self.thumb = thumb
        self.preview = preview
    }
}

extension ThemeInfo : Decodable {
    static func decode(_ json: JSON) -> Decoded<ThemeInfo> {
        return curry(ThemeInfo.init)
        <^> json <| "id"
        <*> json <| "themeid"
        <*> json <| "tversion"
        <*> json <| "title"
        <*> json <| "privilege"
        <*> json <| "package"
        <*> json <| "filesize"
        <*> json <| "thumb"
        <*> json <|| "preview"
    }
}
