//
//  View+Ext.swift
//
//  Created by Lucca on 2018/7/11.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

#if os(OSX)

public extension NSView {
    /// 是否为RTL布局
    var isRtlLayout: Bool {
        return self.userInterfaceLayoutDirection == .rightToLeft
    }
    
    /// 开启子线程渲染
    public func enableDrawAsync(isEnable: Bool) {
        self.canDrawConcurrently = isEnable
        self.window?.allowsConcurrentViewDrawing = isEnable
        self.layer?.drawsAsynchronously = isEnable
    }
    
    /// 移除所有子View
    /// - parameter recursiveChild: 递归移出子view中包含的view
    public func removeAllSubviews(_ recursiveChild: Bool = true) {
        self.subviews.forEach {
            if recursiveChild { $0.removeAllSubviews() }
            $0.removeFromSuperview()
        }
    }
    
    public var layerBackgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    public var width: CGFloat {
        get {
            return frame.width
        }
        set {
            self.frame = NSMakeRect(frame.left, frame.top,
                                    newValue, frame.height)
        }
    }
    
    public var height: CGFloat {
        get {
            return frame.height
        }
        set {
            self.frame = NSMakeRect(frame.left, frame.top,
                                    frame.width, newValue)
        }
    }
    
    public var size: CGSize {
        return self.frame.size
    }
    
    /// 查找约束
    public func constraint(of firstAttribute: NSLayoutConstraint.Attribute)
        -> NSLayoutConstraint? {
        return self.constraints.first { $0.firstAttribute == firstAttribute }
    }
    
    @objc public func hide() {
        self.isHidden = true
    }
    
    @objc public func hideAfter(delay: TimeInterval) {
        self.perform(#selector(hide), with: nil, afterDelay: delay)
    }
    
    /// 渐隐动画隐藏View
    @objc public func hideWithAnimation(duration: TimeInterval) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().alphaValue = 0
        }) { self.hide() }
    }
    
    /// Alpha动画显示view
    @objc public func showWithAnimation(duration: TimeInterval) {
        self.shown()
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().alphaValue = 1
        }, completionHandler: nil)
    }
    
    @objc public func shown() {
        self.isHidden = false
    }
    
    /// 设置投影
    public func makeShadow(color: NSColor? = nil, radius: CGFloat = 2,
                           opacity: Float = 0.4, offset: CGSize? = nil) {
        self.wantsLayer = true
        self.shadow = NSShadow()
        self.layer?.shadowRadius = radius
        self.layer?.shadowOpacity = opacity
        self.layer?.shadowColor = (color ?? NSColor.black).cgColor
        self.layer?.shadowOffset = offset ?? CGSize(width: 0, height: -1)
    }
    
    /// 忽略内容的抗压缩优先级，NSImageView的图片比窗口大的时候，
    /// Window会被拉大，降低此优先级可以阻止其拉伸窗口
    public func ignoreContentResistance() {
        self.setContentCompressionResistancePriority(
            .defaultLow, for: .horizontal)
        self.setContentCompressionResistancePriority(
            .defaultLow, for: .vertical)
    }
}

#elseif os(iOS)

public extension UIView {
    /// 是否为RTL布局
    var isRtlLayout: Bool {
        if #available(iOS 10.0, *) {
            return self.effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            return false
        }
    }
    
    /// 开启子线程渲染
    public func enableDrawAsync(isEnable: Bool) {
        self.layer.drawsAsynchronously = isEnable
    }
    
    /// 移除所有子View
    /// - parameter recursiveChild: 递归移出子view中包含的view
    public func removeAllSubviews(_ recursiveChild: Bool = true) {
        self.subviews.forEach {
            if recursiveChild { $0.removeAllSubviews() }
            $0.removeFromSuperview()
        }
    }
    
    public var layerBackgroundColor: UIColor? {
        get {
            if let colorRef = self.layer.backgroundColor {
                return UIColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.layer.backgroundColor = newValue?.cgColor
        }
    }
    
    public var width: CGFloat {
        get {
            return frame.width
        }
        set {
            self.frame = CGRect(x: frame.left , y: frame.top,
                                width: newValue, height: frame.height)
        }
    }
    
    public var height: CGFloat {
        get {
            return frame.height
        }
        set {
            self.frame = CGRect(x: frame.left , y: frame.top,
                                width: frame.width, height: newValue)
        }
    }
    
    public var size: CGSize {
        return self.frame.size
    }
    
    
    /// 查找约束
    public func constraint(of firstAttribute: NSLayoutConstraint.Attribute)
        -> NSLayoutConstraint? {
            return self.constraints.first { $0.firstAttribute == firstAttribute }
    }
    
    @objc public func hide() {
        self.isHidden = true
    }
    
    @objc public func hideAfter(delay: TimeInterval) {
        self.perform(#selector(hide), with: nil, afterDelay: delay)
    }
    
    /// 渐隐动画隐藏View
    @objc public func hideWithAnimation(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }) { _ in
            self.hide()
        }
    }
    
    /// Alpha动画显示view
    @objc public func showWithAnimation(duration: TimeInterval) {
        self.shown()
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    @objc public func shown() {
        self.isHidden = false
    }
    
    /// 设置投影
    public func makeShadow(color: UIColor? = nil, radius: CGFloat = 2,
                           opacity: Float = 0.4, offset: CGSize? = nil) {
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = (color ?? UIColor.black).cgColor
        self.layer.shadowOffset = offset ?? CGSize(width: 0, height: -1)
    }
    
    /// 忽略内容的抗压缩优先级，NSImageView的图片比窗口大的时候，
    /// Window会被拉大，降低此优先级可以阻止其拉伸窗口
    public func ignoreContentResistance() {
        self.setContentCompressionResistancePriority(
            .defaultLow, for: .horizontal)
        self.setContentCompressionResistancePriority(
            .defaultLow, for: .vertical)
    }
}
#endif
