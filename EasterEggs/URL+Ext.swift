//
//  URL+Ext.swift
//
//  Created by Lucca on 2018/9/28.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//
import Foundation

public extension URL {
    /// 文件是否存在
    public var fileExsists: Bool {
        return self.path.fileExsists
    }
    
    /// 自动创建文件夹
    public func mkdirs() -> Bool {
        return self.path.mkdirs()
    }
    
    /// 是否替身文件
    public var isAliasFile: Bool {
        return (try? resourceValues(forKeys:
            [.isAliasFileKey]))?.isAliasFile ?? false
    }
    
    /// 是否文件夹
    public var isDirectory: Bool {
        return (try? resourceValues(forKeys:
            [.isDirectoryKey]))?.isDirectory ?? false
    }
    
    /// 是否文件
    public var isRegularFile: Bool {
        return (try? resourceValues(forKeys:
            [.isRegularFileKey]))?.isRegularFile ?? false
    }
    
    /// 父文件夹
    public var parentFile: URL {
        return self.deletingLastPathComponent()
    }
    
    /// 是否数据包文件夹
    public var isPackage: Bool {
        return (try? resourceValues(forKeys:
            [.isPackageKey]))?.isPackage ?? false
    }
    
    /// 打开浏览器
    public func openBrowser(inApp: String? = nil) {
        #if os(OSX)
        NSWorkspace.shared.open(
            [self], withAppBundleIdentifier: inApp,
            options: .default, additionalEventParamDescriptor: nil,
            launchIdentifiers: nil)
        #elseif os(iOS)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(
                self, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(self)
        }
        #endif
    }
    
}
