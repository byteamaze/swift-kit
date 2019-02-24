//
//  NSWindow+Ext.swift
//
//  Created by Lucca on 2018/7/3.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

#if os(OSX)

public extension NSWindow {
    
    /// window宽度
    public var width: CGFloat {
        get { return frame.size.width }
    }
   
    /// window高度
    public var height: CGFloat {
        get { return frame.size.height }
    }
    
    /// 是否全屏模式
    public var isFullscreen: Bool {
        get {
            return self.styleMask.contains(.fullScreen)
        }
    }
    
    /// 在屏幕中央显示Window
    public func centerInScreen() {
        if let screenSize = screen?.frame.size {
            let x = (screenSize.width - width) / 2
            let y = (screenSize.height - height) / 2
            self.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
}
#endif
