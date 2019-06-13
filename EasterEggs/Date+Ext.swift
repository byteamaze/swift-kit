//
//  Date+Ext.swift
//
//  Created by Lucca on 2018/9/14.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//
import Foundation

public extension Date {

    public var rfc822String: String {
        get {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            return formatter.string(from: self)
        }
    }
    
    /// 格式化时间
    public func format(by pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter.string(from: self)
    }
}
