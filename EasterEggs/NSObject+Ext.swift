//
//  NSObject+Ext.swift
//
//  Created by Lucca on 2018/3/28.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

public extension NSObject {
    /// from-to之间的随机数
    public func randomInt(from: Int64, to: Int64) -> Int64 {
        let delta = to - from
        return from + (Int64(arc4random()) % delta)
    }
    
    /// App版本
    public static var appVersionName: String {
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"]//主程序版本号
        return majorVersion as! String
    }
    
    /// App数字版本
    public static var appVersion: String {
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleVersion"] //主程序版本号
        return majorVersion as! String
    }

    /// App名
    public static var appDisplayName: String {
        #if os(OSX)
        if let appName = NSRunningApplication.current.localizedName {
            return appName
        }
        #endif
        let infoDictionary = Bundle.main.localizedInfoDictionary!
        let majorName = infoDictionary["CFBundleDisplayName"]
        return majorName as! String
    }
    
    /// App版权
    public static var appCopyright: String {
        let infoDictionary = Bundle.main.infoDictionary!
        let majorName = infoDictionary["NSHumanReadableCopyright"]
        return majorName as! String
    }
    
    /// App包名(唯一标志符)
    public static var appBundleIdentifier: String {
        let infoDict = Bundle.main.infoDictionary!
        let identifier = infoDict[kCFBundleIdentifierKey as String]
        return identifier as! String
    }
}
