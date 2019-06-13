//
//  NSNumber+Ext.swift
//
//  Created by Lucca on 2018/9/28.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//
import Foundation

public extension Double {
    
    /// 最大分数位数，小数点后保留maxFractionDigits位
    public func format(_ maxFractionDigits: Int16) -> String {
        return String(format: "%.\(maxFractionDigits)f", self)
    }
    
    /// 精确四舍五入
    public func rounded(scale: Int16) -> Double {
        let roundUp = NSDecimalNumberHandler(
            roundingMode: .plain, scale: scale, raiseOnExactness: false,
            raiseOnOverflow: false, raiseOnUnderflow: false,
            raiseOnDivideByZero: true)
        return NSDecimalNumber(value: self)
            .rounding(accordingToBehavior: roundUp).doubleValue
    }
}

public extension Float {
    
    /// 最大分数位数，小数点后保留maxFractionDigits位
    public func format(_ maxFractionDigits: Int16) -> String {
        return String(format: "%.\(maxFractionDigits)f", self)
    }
    
    /// 精确四舍五入
    public func rounded(scale: Int16) -> Float {
        let roundUp = NSDecimalNumberHandler(
            roundingMode: .plain, scale: scale, raiseOnExactness: false,
            raiseOnOverflow: false, raiseOnUnderflow: false,
            raiseOnDivideByZero: true)
        return NSDecimalNumber(value: self)
            .rounding(accordingToBehavior: roundUp).floatValue
    }
}

public extension CGFloat {
    /// 角度转弧度
    public var degreeToRadians: CGFloat {
        return self * CGFloat.pi / 180
    }
    
    /// 弧度转角度
    public var radiansToDegree: CGFloat {
        return self * 180 / CGFloat.pi
    }
}
