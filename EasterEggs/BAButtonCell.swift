//
//  BAButtonCell.swift
//
//  Created by Lucca on 2018/9/20.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

#if os(OSX)
import Cocoa

@IBDesignable public class BAButtonCell: NSButtonCell {
    @IBInspectable public var enableHighlight: Bool = true // 允许高亮
    @IBInspectable public var color: NSColor? = nil // 背景色
    @IBInspectable public var highlightColor: NSColor? = nil // 高亮色
    
    public var edgetInsets: NSEdgeInsets? = nil // 绘制内容的边距
    public var titleDimWhenDisable: Bool? // Disable状态文字是否变色
    
    @IBInspectable public var drawImageAsBackground: Bool = false // 将图片当做背景图绘制
    
    /// 设置按钮图片与背景色，默认点击状态下不改变按钮颜色，
    /// enableHighlight为true时候，设置buttonType为
    /// momentaryChange可以防止点击状态下出现异常的背景色
    public init(withImage image: NSImage? = nil, color: NSColor? = nil,
                highlightColor: NSColor? = nil) {
        super.init(imageCell: image)
        self.color = color
        self.highlightColor = highlightColor
        self.enableHighlight = false
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 拦截高亮状态，更新Button的背景色
    override public func highlight(_ flag: Bool, withFrame f: NSRect, in v: NSView) {
        if enableHighlight { super.highlight(flag, withFrame: f, in: v) }
        v.layerBackgroundColor = flag ? highlightColor : color
    }
    
    override public func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        // button不可点击时，字体颜色不需要跟着变
        let dimWhenDisable = titleDimWhenDisable ?? imageDimsWhenDisabled
        let newTitle = dimWhenDisable ? title : self.attributedTitle
        return super.drawTitle(newTitle, withFrame: frame, in: controlView)
    }
    
    /// 更新Button绘制的区域
    override public func drawingRect(forBounds rect: NSRect) -> NSRect {
        guard let insets = self.edgetInsets else { return rect }
        return NSRect(x: insets.left, y: insets.top,
                      width: rect.width-insets.left-insets.right,
                      height: rect.height-insets.top-insets.bottom)
    }
    
    override public func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
        if drawImageAsBackground { // 图片当背景，铺满View
            let cellFrame = controlView.bounds
            if let context = NSGraphicsContext.current {
                context.saveGraphicsState()
                if context.isFlipped {
                    context.cgContext.scaleBy(x: 1, y: -1)
                    context.cgContext.translateBy(x: 0, y: -cellFrame.height)
                }
                // 点击效果
                let frac: CGFloat = isHighlighted ? 0.8 : 1
                self.image?.draw(in: cellFrame, from: .zero,
                                 operation: .darken, fraction: frac)
                context.restoreGraphicsState()
            }
        } else {
            super.drawImage(image, withFrame: frame, in: controlView)
        }
    }
}
#endif
