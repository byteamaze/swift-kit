//
//  Data+Hex.swift
//
//  Created by Lucca on 2018/9/14.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

import Foundation
import CommonCrypto

public extension Data {
    public static func fromHexString (_ string: String) -> Data {
        let data = NSMutableData()
        
        for idx in stride(from: 0, to: string.length, by: 2)  {
            if let temp = string.subString(from: idx, to: idx + 2),
                temp.lengthOfBytes(using: String.Encoding.utf8) == 2 {
                let scanner = Scanner(string: temp)
                var value: CUnsignedInt = 0
                scanner.scanHexInt32(&value)
                data.append(&value, length: 1)
            }
        }
        
        return data as Data
    }
    
    /// 16进制字符串
    public func hexString() -> String {
        return map { String(format: "%02hhX", $0) }.joined()
    }
    
    /// md5加密值
    public var md5: String {
        return (self as NSData).md5 as String
    }
    
    /// 写入Data到文件
    public func write(to path: String, options: Data.WritingOptions = .atomic) throws {
        do {
            try self.write(to: URL(fileURLWithPath: path), options: options)
        } catch { throw error }
    }
}

public extension NSData {
    /// md5加密值
    public var md5: NSString {
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        
        CC_MD5(bytes, CC_LONG(length), md5Buffer)
        
        let output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH * 2))
        for i in 0..<digestLength {
            output.appendFormat("%02x", md5Buffer[i])
        }
        
        md5Buffer.deallocate()
        return NSString(format: output)
    }
}
