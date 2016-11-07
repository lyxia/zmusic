import Foundation

public func example(des: String, action: ()->()) {
    print("--------\(des) example------------")
    action()
}

public func delay(delay: Double, closure: @escaping ()->()) {
    let delayTime = DispatchTime.now() + DispatchTimeInterval.seconds(Int(delay))
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        closure()
    }
}
