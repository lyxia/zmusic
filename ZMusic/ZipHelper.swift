//
//  ZipHelper.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/31.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import Foundation
import SSZipArchive
import RxSwift

enum ZIPError : Swift.Error {
    case ZIPErrorCreateDir
    case ZIPErrorNotADocumentDir
    case ZIPErrorCoverToUrl
    case ZIPErrorDownload
    case ZIPErrorWriteToFile
    case ZIPErrorUnzip
    case ZIPErrorNoUserDocumentDirectory
    case ZIPCoverToBoundle
}

struct ZipHelper {
    static func downloadZipFile(fileUrl: String, component:String) -> Observable<String> {
        return Observable.zip(getDownloadedZipUrl(url: fileUrl, component: component), getUnZipURL(url: fileUrl, component: component)) {(downloadZipURl, unZipUrl) in
            //zip包不存在，并且解压包也不存在，则要下载
            if !FileManager.default.fileExists(atPath: downloadZipURl.path) &&
                !FileManager.default.fileExists(atPath: unZipUrl.path){
                //writing
                var data: Data
                do {
                    data = try Data(contentsOf: URL(string:fileUrl)!)
                } catch (_) {
                    throw ZIPError.ZIPErrorDownload
                }
                
                do {
                    try data.write(to: downloadZipURl)
                }
                catch (_){
                    throw ZIPError.ZIPErrorWriteToFile
                }
            }
            return downloadZipURl.path
        }
    }
    
    static func getBundle(zipUrl:String, component:String) -> Observable<Bundle> {
        return Observable.zip(downloadZipFile(fileUrl: zipUrl, component: component), getUnZipURL(url: zipUrl, component: component)) {(filePath, unZipUrl) in
            return (filePath, unZipUrl.path)
        }.map { (filePath, unZipToPath) -> Bundle in
            if !FileManager.default.fileExists(atPath: unZipToPath) {
                if !SSZipArchive.unzipFile(atPath: filePath, toDestination: unZipToPath) {
                    throw ZIPError.ZIPErrorUnzip
                } else {
                    do {
                        try FileManager.default.removeItem(atPath: filePath)
                    } catch {
                    }
                }
            }
            if let bundle = Bundle(path: unZipToPath) {
                return bundle
            } else {
                throw ZIPError.ZIPCoverToBoundle
            }
        }
    }
    
    //abc/ddd/ed.zip return ad.zip
    static func getFileName(url: String) -> Observable<String> {
        return Observable.create { (observer) -> Disposable in
            if let fileName = URL(string: url)?.lastPathComponent {
                observer.onNext(fileName)
                observer.onCompleted()
            } else {
                observer.onError(ZIPError.ZIPErrorCoverToUrl)
            }
            return Disposables.create()
        }
    }
    
    //abc/ddd/ed.zip return ed
    static func getDirectoryName(url: String) -> Observable<String> {
        return getFileName(url: url).map { (fileName) -> String in
            return fileName.substring(to: fileName.index(fileName.endIndex, offsetBy: -4))
        }
    }
    
    //判断目录是否存在，不存在就创建
    static func dirIsExistsAndCreate(dirUrl: URL) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            let fileManager = FileManager.default
            var isDir : ObjCBool = false
            if fileManager.fileExists(atPath: dirUrl.path, isDirectory:&isDir) {
                if isDir.boolValue {
                    // file exists and is a directory
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    // file exists and is not a directory
                    observer.onError(ZIPError.ZIPErrorNotADocumentDir)
                }
            } else {
                // file does not exist
                do {
                    try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
                    observer.onNext(true)
                    observer.onCompleted()
                } catch (_) {
                    observer.onError(ZIPError.ZIPErrorCreateDir)
                }
            }
            return Disposables.create()
        })
    }
    
    static func getUserDocumentDirectory() -> Observable<URL> {
        return Observable.create { (observer) -> Disposable in
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                observer.onNext(dir)
                observer.onCompleted()
            } else {
                observer.onError(ZIPError.ZIPErrorNoUserDocumentDirectory)
            }
            return Disposables.create()
        }
    }
    
    //下载下来的zip路径
    static func getDownloadedZipUrl(url: String, component:String) -> Observable<URL> {
        let dirUrlIsExist = getUserDocumentDirectory().map { (userDocumentDir) -> URL in
            return userDocumentDir.appendingPathComponent(component)
        }.flatMap { (dirUrl) -> Observable<Bool> in
            return dirIsExistsAndCreate(dirUrl: dirUrl)
        }
        
        return Observable.zip(dirUrlIsExist, getUserDocumentDirectory(), getFileName(url: url)){(dirIsExist, dir, fileName) in
            return dir.appendingPathComponent(component + "/" + fileName)
        }
    }
    
    //解压后的zip路径
    static func getUnZipURL(url: String, component:String) -> Observable<URL> {
        let dirUrlIsExist = getUserDocumentDirectory().map { (userDocumentDir) -> URL in
            return userDocumentDir.appendingPathComponent(component)
            }.flatMap { (dirUrl) -> Observable<Bool> in
                return dirIsExistsAndCreate(dirUrl: dirUrl)
        }
        
        return Observable.zip(dirUrlIsExist, getUserDocumentDirectory(), getDirectoryName(url: url)){(dirIsExist, dir, directoryName) in
            return dir.appendingPathComponent(component + "/" + directoryName)
        }
    }
}
