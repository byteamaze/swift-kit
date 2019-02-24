//
//  String+Ext.swift
//
//  Created by Lucca on 2018/7/3.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

import Foundation

public extension String {
    /// 国际化翻译
    public var translate: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
    
    /// 是否为隐藏文件
    public var isFileHidden: Bool {
        return self.fileName.starts(with: ".")
    }

    /// 是否为文件夹
    public var isDirectory: Bool {
        return URL(fileURLWithPath: self).isDirectory
    }
    
    /// 是否为文件
    public var isRegularFile: Bool {
        return URL(fileURLWithPath: self).isRegularFile
    }
    
    /// 是否替身文件
    public var isAliasFile: Bool {
        return URL(fileURLWithPath: self).isAliasFile
    }
    
    #if os(OSX)
    /// 是否包文件夹
    public var isFilePackage: Bool {
        return NSWorkspace.shared.isFilePackage(atPath: self)
    }
    #endif
    
    /// 文件扩展名
    public var fileExtension: String? {
        let ext = NSString(string: self).pathExtension
        return ext.isEmpty() ? nil : ext
    }
    
    /// 文件显示名称
    public var fileDisplayName: String {
        return FileManager.default.displayName(atPath: self)
    }
    
    /// 文件名称
    public var fileName: String {
        return NSString(string: self).lastPathComponent
    }

    /// 没有后缀名的文件名称
    public var fileNameWithoutExtension: String {
        let fn = self.fileName
        if !fn.isEmpty(), let extLen = fn.fileExtension?.length {
            return fn.subString(to: self.length - extLen - 1)
        }
        return fn
    }
    
    /// 文件创建时间
    public var fileCreationDate: Date? {
        if let attr = try? FileManager.default.attributesOfItem(atPath: self) {
            return attr[FileAttributeKey.creationDate] as? Date
        }
        return nil
    }
    
    /// 文件创建时间
    public var fileLastModified: Date? {
        if let attr = try? FileManager.default.attributesOfItem(atPath: self) {
            return attr[FileAttributeKey.modificationDate] as? Date
        }
        return nil
    }
    
    /// 父文件夹
    public var parentFile: String {
        return URL(fileURLWithPath: self).parentFile.path
    }
    
    /// 字符串长度
    public var length: Int {
        get {
            return NSString(string: self).length
        }
    }
    
    /// 截取字符串
    public func subString(from: Int, to: Int) -> String? {
        if(from>to || from >= self.length || from+to>self.length) {
            return nil
        }
        return NSString(string: self)
            .substring(with: NSMakeRange(from, to-from))
    }
    
    /// 截取字符串
    public func subString(from: Int) -> String? {
        if from >= self.length {
            return nil
        }
        return NSString(string: self)
            .substring(with: NSMakeRange(from, self.length-from))
    }
    
    /// 截取字符串
    public func subString(to toIndex: Int) -> String{
        var to = toIndex
        if(to < 0) { // 负数，则从最后一位到着取
            to = self.length + to
        }
        
        if self.length < to {
            return self
        }
        
        return NSString(string: self).substring(with: NSMakeRange(0, to))
    }
    
    /// 是否为空
    public func isEmpty() -> Bool {
        return NSString(string: self).length == 0
    }
    
    /// 16进制颜色
    #if os(OSX)
    public var hexColor: NSColor? {
        return NSColor(hex: self)
    }
    #elseif os(iOS)
    public var hexColor: UIColor? {
        return UIColor(hex: self)
    }
    #endif
    
    /// base64编码
    public func base64Encode() -> String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
    
    /// base64解码
    public func base64Decode() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    /// 是否为base64编码字符串
    public func isBase64() -> Bool {
        if let _ = Data(base64Encoded: self) {
            return true
        }
        return false
    }
    
    /// 自动创建文件夹
    public func mkdirs() -> Bool {
        if !FileManager.default.fileExists(atPath: self) {
            do {
                try FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return false
            }
        }
        return true
    }

    /// 路径文件大小
    public var fileSize : UInt64 {
        let attr = try? FileManager.default.attributesOfItem(atPath: self)
        guard let fileSize = attr?[FileAttributeKey.size] as? UInt64 else {
            return 0
        }
        return fileSize
    }
    
    /// 文件是否存在
    public var fileExsists: Bool {
        return FileManager.default.fileExists(atPath: self)
    }
    
    /// 删除文件
    public func fileRemove() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: self)
            return true
        } catch { return false }
    }
    
    /// md5加密值
    public var md5: String? {
        return self.data(using: .utf8)?.md5
    }
    
    /// 设置文字显示属性
    #if os(OSX)
    public func attributeText(color: NSColor? = nil, font: NSFont? = nil,
                       backgroundColor: NSColor? = nil,
                       paragraphStyle: NSParagraphStyle? = nil,
                       underlineStyle: NSUnderlineStyle? = nil,
                       underlineColor: NSColor? = nil,
                       strokeWidth: Int? = nil) -> NSAttributedString {
        var attr = [NSAttributedStringKey: Any]()
        if let color = color { // 前景色
            attr[.foregroundColor] = color
        }
        if let bgColor = backgroundColor { // 背景色
            attr[.backgroundColor] = bgColor
        }
        if let font = font { // 字体
            attr[.font] = font
        }
        if let underlineColor = underlineColor { // 下划线
            attr[.underlineColor] = underlineColor
        }
        if let underlineStyle = underlineStyle { // 下划线
            attr[.underlineStyle] = underlineStyle.rawValue
        }
        if let paragraphStyle = paragraphStyle { // 段落
            attr[.paragraphStyle] = paragraphStyle
        }
        if let strokeWidth = strokeWidth {
            attr[.strokeWidth] = strokeWidth
            attr[.strokeColor] = color
        }
        
        return NSAttributedString(string: self, attributes: attr)
    }
    #elseif os(iOS)
    public func attributeText(color: UIColor? = nil, font: UIFont? = nil,
                              backgroundColor: UIColor? = nil,
                              paragraphStyle: NSParagraphStyle? = nil,
                              underlineStyle: NSUnderlineStyle? = nil,
                              underlineColor: UIColor? = nil,
                              strokeWidth: Int? = nil) -> NSAttributedString {
        var attr = [NSAttributedStringKey: Any]()
        if let color = color { // 前景色
            attr[.foregroundColor] = color
        }
        if let bgColor = backgroundColor { // 背景色
            attr[.backgroundColor] = bgColor
        }
        if let font = font { // 字体
            attr[.font] = font
        }
        if let underlineColor = underlineColor { // 下划线
            attr[.underlineColor] = underlineColor
        }
        if let underlineStyle = underlineStyle { // 下划线
            attr[.underlineStyle] = underlineStyle.rawValue
        }
        if let paragraphStyle = paragraphStyle { // 段落
            attr[.paragraphStyle] = paragraphStyle
        }
        if let strokeWidth = strokeWidth {
            attr[.strokeWidth] = strokeWidth
            attr[.strokeColor] = color
        }
        
        return NSAttributedString(string: self, attributes: attr)
    }
    #endif
    
    /// 字符串对应的图片资源
    #if os(OSX)
    public var image: NSImage? {
        return NSImage(imageLiteralResourceName: self)
    }
    #elseif os(iOS)
    public var image: UIImage? {
        return UIImage(imageLiteralResourceName: self)
    }
    #endif
}
