//
//  JSON+Ext.swift
//
//  Created by Lucca on 2018/9/14.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

import Foundation

public extension String {
    
    /// json字符串转字典
    public func jsonDictionary() -> [String: Any?]? {
        if let data = self.data(using: .utf8) {
            let result = try? JSONSerialization.jsonObject(
                with: data, options: .allowFragments)
            return result as? [String: Any?]
        }
        return nil
    }
    
    /// json字符串转数组
    public func jsonArray() -> [Any?]? {
        if let data = self.data(using: .utf8) {
            let result = try? JSONSerialization.jsonObject(
                with: data, options: .allowFragments)
            return result as? [Any?]
        }
        return nil
    }
}

public extension Data {
    
    /// jsonData转字典
    public func jsonDictionary() -> [String: Any?]? {
        let result = try? JSONSerialization.jsonObject(
            with: self, options: .allowFragments)
        return result as? [String: Any?]
    }
    
    /// jsonData转数组
    public func jsonArray() -> [Any?]? {
        let result = try? JSONSerialization.jsonObject(
            with: self, options: .allowFragments)
        return result as? [Any?]
    }
}

public extension NSDictionary {
    
    /// 转为JSON
    public func jsonData() -> Data? {
        return try? JSONSerialization.data(
            withJSONObject: self, options: .prettyPrinted)
    }
    
    /// 转为JSON字符串
    public func jsonString() -> String? {
        if let data = jsonData() {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
}

public extension NSArray {
    
    // 转为JSON
    public func jsonData() -> Data? {
        return try? JSONSerialization.data(
            withJSONObject: self, options: .prettyPrinted)
    }
    
    // 转为JSON字符串
    public func jsonString() -> String? {
        if let data = jsonData() {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
