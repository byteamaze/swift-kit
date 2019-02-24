//
//  Image+Ext.swift
//
//  Created by Lucca on 2018/7/3.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

#if os(OSX)
public extension NSImage {
    
    /// CGImage
    public var cgImage: CGImage? {
        return self.cgImage(forProposedRect:
            nil, context: nil, hints: nil)
    }
    
    /// 图片真实尺寸
    public var realSize: CGSize {
        return self.cgImage?.size ?? self.size
    }
    
    /// 根据尺寸缩放图片
    /// - parameter size: 期望最大的宽/高，当未指定limit时，任何一边都不能大于此值
    /// - parameter allowScaleUp: 当图片2边都小于Size的时候，是否放大到Size，
    /// 如果设置为false，则返回原图
    /// - parameter limit: 指定此值后，限制任何一边都不能小于该值
    /// - parameter retina: 是否考虑屏幕密度。如果为true: 当屏幕密度大于1时，
    /// 返回的NSImage.size比指定的width&height要小。默认为：false
    public func scaled(size: CGFloat, allowScaleUp: Bool = false,
                       limit: CGFloat? = nil, retina: Bool = false) -> NSImage {
        if let imageRef = self.cgImage {
            let imageW = CGFloat(imageRef.width)
            let imageH = CGFloat(imageRef.height)
            // 不允许放大图片，则返回原图即可
            if !allowScaleUp, imageW <= size, imageH <= size { return self }
            
            var scale = min(size / imageW, size / imageH)
            guard let limit = limit else {
                return self.scaled(scale: scale, retina: retina)
            }
            
            // 确保缩小后2边都不小于limit
            if scale * imageW < limit { scale = limit / imageW }
            if scale * imageH < limit { scale = limit / imageH }
            return self.scaled(scale: scale, retina: retina)
        }

        return self
    }
    
    /// 比例缩放图片
    public func scaled(scale: CGFloat, retina: Bool = false) -> NSImage {
        if let imageRef = self.cgImage?.scaled(scale: scale) {
            if retina {
                // 以下代码在Retina屏幕下，返回高清图片
                let sScale = NSScreen.main!.backingScaleFactor
                let size = imageRef.size.multiply(by: 1 / sScale)
                return NSImage(cgImage: imageRef, size: size)
            } else {
                let rep = NSBitmapImageRep(cgImage: imageRef)
                let destImage = NSImage(size: rep.size)
                destImage.addRepresentation(rep)
                return destImage
            }
        }
        return self
    }
    
    /// CenterCrop方式裁切
    /// - parameter retina: 是否考虑屏幕密度。如果为true: 当屏幕密度大于1时，
    /// 返回的NSImage.size比指定的width&height要小。默认为：false
    public func centerCrop(width destW: CGFloat,
                           height toH: CGFloat? = nil,
                           retina: Bool = false) -> NSImage? {
        let destH = toH ?? destW
        let ratio = destW / destH
        var width: CGFloat!, height: CGFloat!
        if (destW / self.size.width) > (destH / self.size.height) {
            width = self.size.width
            height = self.size.width / ratio
        } else {
            width = self.size.height * ratio
            height = self.size.height
        }
        let fromRect = CGRect(x: (self.size.width - width) / 2,
                              y: (self.size.height - height) / 2,
                              width: width, height: height)
        let imageRect = CGRect(origin: .zero, size:
            CGSize(width: destW, height: destH))
        // 指定NSBitmapImageRep大小，防止Retina屏幕下NSImage与图片实际尺寸不同
        if let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(destW), pixelsHigh: Int(destH), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) {
            rep.size = imageRect.size
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
            self.draw(in: imageRect, from: fromRect,
                      operation: .copy, fraction: 1.0)
            // 在Retina屏幕下，返回高清图片
            let sScale = NSScreen.main!.backingScaleFactor
            let size = imageRect.size.multiply(
                by: !retina ? 1 : (1 / sScale))
            let destImage = NSImage(size: size)
            destImage.addRepresentation(rep)
            return destImage
        }
        
        return nil
    }
    
    /// 旋转图片
    public func rotated(degree: Int32) -> NSImage? {
        if let image = self.cgImage?.rotated(degree: degree) {
            return NSImage(cgImage: image, size: self.size)
        }
        return nil
    }

    /// 改变Image颜色值
    public func tint(withColor tintColor: NSColor) -> NSImage {
//        if !self.isTemplate { return self }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        tintColor.set()
        CGRect(origin: .zero, size: image.size).fill(using: .sourceAtop)
        image.unlockFocus()
        image.isTemplate = false
        return image
    }
    
    /// 是否为GIF动图
    public var isGif: Bool {
        var isGIF = false
        for rep in self.representations {
            if let bitmapRep = rep as? NSBitmapImageRep {
                let frameCount = bitmapRep.value(forProperty: .frameCount)
                isGIF = ((frameCount as? Int) ?? 0) > 1
                break
            }
        }
        
        return isGIF
    }
    
    /// 绘制圆角图片
    public func rounded(cornerRadius r: CGFloat) -> NSImage {
        let image = NSImage(size: self.size)
        let rect = CGRect(origin: .zero, size: self.size)
        image.lockFocus()
        let path = NSBezierPath(roundedRect: rect, xRadius: r, yRadius: r)
        path.setClip()
        self.draw(in: rect)
        image.unlockFocus()
        return image
    }
    
    /// 渐变色图片
    public class func gradient(with size: CGSize, colors: [NSColor],
                        angle: CGFloat = -90) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        let gradient = NSGradient(colors: colors)
        gradient?.draw(in: CGRect(origin: .zero, size: size), angle: angle)
        image.unlockFocus()
        return image
    }
}
#elseif os(iOS)

extension UIImage {
    
    /// Gradient绘制方向
    public enum DrawDirection {
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    /// 图片真实尺寸
    public var realSize: CGSize {
        if let cgImage = self.cgImage {
            return cgImage.size
        }
        return self.size
    }
    
    /// 根据尺寸缩放图片
    /// - parameter size: 期望最大的宽/高，当未指定limit时，任何一边都不能大于此值
    /// - parameter allowScaleUp: 当图片2边都小于Size的时候，是否放大到Size，
    /// 如果设置为false，则返回原图
    /// - parameter limit：指定此值后，限制任何一边都不能小于该值
    public func scaled(toSize size: CGFloat, allowScaleUp: Bool = false,
                       limit: CGFloat? = nil) -> UIImage? {
        if let imageRef = self.cgImage {
            let imageW = CGFloat(imageRef.width)
            let imageH = CGFloat(imageRef.height)
            // 不允许放大图片，则返回原图即可
            if !allowScaleUp, imageW <= size, imageH <= size { return self }
            
            var scale = min(size / imageW, size / imageH)
            guard let limit = limit else {
                return self.scaled(scale)
            }
            
            // 确保缩小后2边都不小于limit
            if scale * imageW < limit { scale = limit / imageW }
            if scale * imageH < limit { scale = limit / imageH }
            return self.scaled(scale)
        }
        
        return self
    }
    
    /// 比例缩放图片
    public func scaled(_ scale: CGFloat) -> UIImage? {
        if let imageRef = self.cgImage?.scaled(scale: scale) {
            return UIImage(cgImage: imageRef, scale: self.scale, orientation: .up)
        }
        return nil
    }
    
    /// CenterCrop方式裁切
    public func centerCrop(width destW: CGFloat, height toH: CGFloat? = nil,
                           scale: CGFloat = 0) -> UIImage? {
        let destH = toH ?? destW
        var drawRect = CGRect(origin: .zero, size:
            CGSize(width: destW, height: destH))
        if (destW / self.size.width) > (destH / self.size.height) {
            drawRect.size.height = destW * self.size.hRatio
            drawRect.origin.y = (destH - drawRect.size.height) / 2
        } else {
            drawRect.size.width = destH * self.size.wRatio
            drawRect.origin.x = (destW - drawRect.size.width) / 2
        }
        
        let size = CGSize(width: destW, height: destH)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: drawRect, blendMode: .copy, alpha: 1)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 旋转图片
    public func rotated(degree: Int32) -> UIImage? {
        if let image = self.cgImage?.rotated(degree: degree) {
            return UIImage(cgImage: image, scale: self.scale,
                           orientation: self.imageOrientation)
        }
        return nil
    }

    /// 改变Image颜色值
    public func tint(withColor tintColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            self.size, false, self.scale)
        self.draw(at: CGPoint.zero)
        tintColor.set()
        let rect = CGRect(origin: .zero, size: self.size)
        UIBezierPath(rect: rect).fill(
            with: .sourceAtop, alpha: 1)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 绘制圆角图片
    public func rounded(cornerRadius r: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            self.size, false, self.scale)
        let rect = CGRect(origin: .zero, size: self.size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: r)
        path.addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 渐变色图片
    public class func gradient(with size: CGSize, colors: [UIColor],
                               direction: DrawDirection = .top,
                               scale: CGFloat = 0) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            let layer = CAGradientLayer()
            layer.frame = CGRect(origin: .zero, size: size)
            layer.colors = colors.map { $0.cgColor }
            switch direction {
            case .top:
                layer.startPoint = CGPoint(x: 0, y: 0)
                layer.endPoint = CGPoint(x:0, y: 1)
            case .bottom:
                layer.startPoint = CGPoint(x: 0, y: 1)
                layer.endPoint = CGPoint(x:0, y: 0)
            case .left:
                layer.startPoint = CGPoint(x: 0, y: 0)
                layer.endPoint = CGPoint(x:1, y: 0)
            case .right:
                layer.startPoint = CGPoint(x: 1, y: 0)
                layer.endPoint = CGPoint(x:0, y: 0)
            case .topLeft:
                layer.startPoint = CGPoint(x: 0, y: 0)
                layer.endPoint = CGPoint(x:1, y: 1)
            case .topRight:
                layer.startPoint = CGPoint(x: 1, y: 0)
                layer.endPoint = CGPoint(x: 0, y: 1)
            case .bottomLeft:
                layer.startPoint = CGPoint(x: 0, y: 1)
                layer.endPoint = CGPoint(x:1, y: 0)
            case .bottomRight:
                layer.startPoint = CGPoint(x: 1, y: 1)
                layer.endPoint = CGPoint(x:0, y: 0)
            }
            layer.render(in: context)
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

#endif

extension CGImage {
    /// 图片真实尺寸
    public var size: CGSize {
        let w = CGFloat(self.width)
        let h = CGFloat(self.height)
        return CGSize(width: w, height: h)
    }
    
    /// 比例缩放图片
    public func scaled(scale: CGFloat) -> CGImage? {
        let destW = Int(CGFloat(self.width) * scale)
        let destH = Int(CGFloat(self.height) * scale)
        let imageRect = CGRect(x: 0, y: 0, width: destW, height: destH)
        
        let cs = self.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: destW, height: destH,
                                bitsPerComponent: self.bitsPerComponent,
                                bytesPerRow: 0, space: cs,
                                bitmapInfo: self.bitmapInfo.rawValue)
        // 指定NSBitmapImageRep大小，防止Retina屏幕下NSImage与图片实际尺寸不同
        context?.draw(self, in: imageRect)
        return context?.makeImage()
    }

    /// 旋转图片
    public func rotated(degree: Int32, mirror: Bool = false) -> CGImage? {
        let swapWidthHeight = (degree % 180 != 0)
        var bytesPerRow = self.bytesPerRow
        let radians = CGFloat(degree).degreeToRadians
        
        // swap width and height
        var dw = self.width, dh = self.height
        if (swapWidthHeight) {
            dw = self.height
            dh = self.width
            // calculate new bytes per row
            bytesPerRow = self.height * (bytesPerRow / self.width)
        }
        
        // redraw image into Context
        var orientedImage: CGImage? = nil
        let colorSpace = self.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        if let context = CGContext(data: nil, width: dw, height: dh, bitsPerComponent: self.bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: self.bitmapInfo.rawValue) {
            let halfWidth = CGFloat(dw) / 2
            let halfHeight = CGFloat(dh) / 2
            context.translateBy(x: halfWidth, y: halfHeight)
            if (mirror) { context.scaleBy(x: -1, y: 1) }
            context.rotate(by: radians)
            if (swapWidthHeight) {
                context.translateBy(x: -halfHeight, y: -halfWidth)
            } else {
                context.translateBy(x: -halfWidth, y: -halfHeight)
            }
            let imageRect = CGRect(x: 0, y: 0, width:
                self.size.width, height: self.size.height)
            context.draw(self, in: imageRect)
            orientedImage = context.makeImage()
        }
        return orientedImage;
    }
}
