//
//  Rect+Ext.swift
//
//  Created by Lucca on 2018/7/4.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

import Foundation

public extension CGRect {
    
    /// 左侧的坐标
    public var left: CGFloat {
        get { return origin.x }
        set { self.origin.x = newValue }
    }

    /// 右侧的坐标
    public var right: CGFloat {
        get { return origin.x + width }
        set { self.origin.x = newValue - width }
    }

    /// 顶部坐标
    public var top: CGFloat {
        get { return origin.y }
        set { self.origin.y = newValue }
    }
    
    /// 底部的坐标
    public var bottom: CGFloat {
        get { return origin.y + height }
        set { self.origin.y = newValue - height }
    }
    
    /// 中心点
    public var center: CGPoint {
        return CGPoint(x: self.left + self.width / 2,
                       y: self.top + self.height / 2)
    }
    
    /// 乘积
    func multiply(by mul: CGFloat) -> CGRect {
        return CGRect(x: self.left * mul, y: self.top * mul,
                      width: self.width * mul, height: self.height * mul)
    }
    
    /// 相加
    public func plus(_ rect: CGRect) -> CGRect {
        return CGRect(x: self.origin.x + rect.origin.x,
                      y: self.origin.y + rect.origin.y,
                      width: self.width + rect.width,
                      height: self.height + rect.height)
    }
}

extension CGSize {
    public var hRatio: CGFloat { return height / width } // h = hRatio * width
    
    public var wRatio: CGFloat { return width / height } // w = wRatio * height
    
    /// 交换宽高
    public func swap() -> CGSize {
        return CGSize(width: self.height, height: self.width)
    }

    /// 乘积
    public func multiply(by mul: CGFloat) -> CGSize{
        return CGSize(width: self.width * mul,
                      height: self.height * mul)
    }
    
    /// 相加
    public func plus(_ size: CGSize) -> CGSize {
        return CGSize(width: self.width + size.width,
                      height: self.height + size.height)
    }
}
