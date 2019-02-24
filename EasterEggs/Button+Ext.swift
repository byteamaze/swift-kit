//
//  Button+Ext.swift
//
//  Created by Lucca on 2018/9/20.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//
public struct FABTheme {
    public static let `default` = FABTheme()
    #if os(OSX)
    var textColor = NSColor.white
    var backgroundColor = NSColor(hex: "#FF5722")
    #elseif os(iOS)
    var textColor = UIColor.white
    var backgroundColor = UIColor(hex: "#FF5722")
    #endif
}

#if os(OSX)

public extension NSControl {
    /// 绑定按钮点击事件
    public func addTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }
    
    /// 重置事件
    public func clearTargetAndAction() {
        self.target = nil
        self.action = nil
    }
}

public extension NSButton {
    /// 构造自定义cell的Button
    public convenience init(cell: NSButtonCell? = nil, isBordered: Bool = true) {
        self.init(frame: NSRect.zero)
        if let cell = cell { self.cell = cell }
        self.isBordered = isBordered
    }
    
    /// Button Cell
    public var buttonCell: NSButtonCell? {
        return (self.cell as? NSButtonCell)
    }
    
    /// BA Button Cell
    public var baButtonCell: BAButtonCell? {
        return (self.cell as? BAButtonCell)
    }
    
    /// 生成悬浮按钮
    public class func makeFloatingActionButton(in view: NSView?,
        size: CGFloat, icon: NSImage, theme: FABTheme = .default) -> NSButton {
        let btnSize = CGSize(width: size, height: size)
        let button = NSButton(frame: NSRect(origin: .zero, size: btnSize))
        button.cell = BAButtonCell()
        button.setAsFloatingAction(
            backgroundColor: theme.backgroundColor, icon: icon)
        guard let view = view else { return button }
        // add button to view
        view.addSubview(button)
        let cs1 = NSLayoutConstraint(
            item: button, attribute: .width, relatedBy: .equal, toItem: nil,
            attribute: .width, multiplier: 1, constant: btnSize.width)
        let cs2 = NSLayoutConstraint(
            item: button, attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .height, multiplier: 1, constant: btnSize.height)
        let cs3 = NSLayoutConstraint(
            item: button, attribute: .trailing, relatedBy: .equal, toItem: view,
            attribute: .trailing, multiplier: 1, constant: 16)
        let cs4 = NSLayoutConstraint(
            item: button, attribute: .bottom, relatedBy: .equal, toItem: view,
            attribute: .bottom, multiplier: 1, constant: 24)
        button.addConstraints([cs1, cs2, cs3, cs4])
        return button
    }
    
    /// 设置为悬浮按钮
    func setAsFloatingAction(backgroundColor: NSColor, icon: NSImage) {
        let btnCell = self.cell as? BAButtonCell
        btnCell?.image = icon
        btnCell?.enableHighlight = false
        btnCell?.color = backgroundColor
        btnCell?.highlightColor = backgroundColor.shadow(withLevel: 0.2)
        self.isBordered = false
        self.layerBackgroundColor = backgroundColor
        self.layer?.masksToBounds = false
        self.layer?.cornerRadius = self.width / 2
        self.shadow = NSShadow()
        self.layer?.shadowRadius = 2
        self.layer?.shadowOpacity = 0.4
        self.layer?.shadowColor = NSColor.black.cgColor
        self.layer?.shadowOffset = CGSize(width: 0, height: 1)
        self.image = icon
    }
}

extension NSCell {
    /// 自适应文字宽度
    /// parameter extend: 在计算出的宽度上扩增值
    public func sizeToFitWidth(extend: CGFloat = 0) -> CGFloat? {
        guard let view = self.controlView,
            let cellFont = self.font else { return nil }
        
        let titleSEL = Selector("title")
        let textSEL = Selector("stringValue")
        var width = view.width
        if view.responds(to: titleSEL) {
            width = extend + (self.title as NSString).size(
                withAttributes: [.font : cellFont]).width
        } else if view.responds(to: textSEL) {
            width = extend + (self.stringValue as NSString).size(
                withAttributes: [.font : cellFont]).width
        }
        view.constraint(of: .width)?.constant = width
        view.updateConstraints()
        return width
    }
}

#elseif os(iOS)

extension UIButton {
    /// 生成悬浮按钮
    public class func makeFloatingActionButton(
        in view: UIView?, size: CGFloat, icon: UIImage,
        theme: FABTheme = .default) -> UIButton {
        let btnSize = CGSize(width: size, height: size)
        let button = UIButton(frame: CGRect(origin: .zero, size: btnSize))
        button.setAsFloatingAction(
            backgroundColor: theme.backgroundColor, icon: icon)
        guard let view = view else { return button }
        // add button to view
        view.addSubview(button)
        let cs1 = NSLayoutConstraint(
            item: button, attribute: .width, relatedBy: .equal, toItem: nil,
            attribute: .width, multiplier: 1, constant: btnSize.width)
        let cs2 = NSLayoutConstraint(
            item: button, attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .height, multiplier: 1, constant: btnSize.height)
        let cs3 = NSLayoutConstraint(
            item: button, attribute: .trailing, relatedBy: .equal, toItem: view,
            attribute: .trailing, multiplier: 1, constant: 16)
        let cs4 = NSLayoutConstraint(
            item: button, attribute: .bottom, relatedBy: .equal, toItem: view,
            attribute: .bottom, multiplier: 1, constant: 24)
        button.addConstraints([cs1, cs2, cs3, cs4])
        return button
    }
    
    /// 设置为悬浮按钮
    func setAsFloatingAction(backgroundColor: UIColor, icon: UIImage) {
        self.setImage(icon, for: .normal)
        self.setImage(icon, for: .highlighted)
        let backgroundNoamrl = backgroundColor.image(
            withSize: self.size, radius: self.size.width / 2)
        self.setBackgroundImage(backgroundNoamrl, for: .normal)
        let backgroundHighlight = backgroundColor
            .blended(withFraction: 0.3, of: .white)
            .image(withSize: self.size, radius: self.size.width / 2)
        self.setBackgroundImage(backgroundHighlight, for: .highlighted)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.4
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
}

#endif
