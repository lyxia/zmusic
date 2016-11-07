//: Playground - noun: a place where people can play

import UIKit
import RxSwift

print("111")

let operationQueue = OperationQueue()
operationQueue.maxConcurrentOperationCount = 2
Observable<String>.create { (observer) -> Disposable in
    observer.onNext("1")
    observer.onCompleted()
    print("obser----\(Thread.current)")"
    return Disposables.create()
    }
    .subscribeOn(OperationQueueScheduler(operationQueue: operationQueue))
    .observeOn(MainScheduler.instance)
    .subscribe { (event) in
        print(Thread.current)
}