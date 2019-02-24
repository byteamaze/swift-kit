//
//  YYImage.m
//  YYImage <https://github.com/ibireme/YYImage>
//
//  Created by ibireme on 14/10/20.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYImage.h"

/**
 An array of NSNumber objects, shows the best order for path scale search.
 e.g. iPhone3GS:@[@1,@2,@3] iPhone5:@[@2,@3,@1]  iPhone6 Plus:@[@3,@2,@1]
 */
static NSArray *_NSBundlePreferredScales() {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [NSScreen mainScreen].backingScaleFactor;
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

/**
 Add scale modifier to the file name (without path extension),
 From @"name" to @"name@2x".
 
 e.g.
 <table>
 <tr><th>Before     </th><th>After(scale:2)</th></tr>
 <tr><td>"icon"     </td><td>"icon@2x"     </td></tr>
 <tr><td>"icon "    </td><td>"icon @2x"    </td></tr>
 <tr><td>"icon.top" </td><td>"icon.top@2x" </td></tr>
 <tr><td>"/p/name"  </td><td>"/p/name@2x"  </td></tr>
 <tr><td>"/path/"   </td><td>"/path/"      </td></tr>
 </table>
 
 @param scale Resource scale.
 @return String by add scale modifier, or just return if it's not end with file name.
 */
static NSString *_NSStringByAppendingNameScale(NSString *string, CGFloat scale) {
    if (!string) return nil;
    if (fabs(scale - 1) <= __FLT_EPSILON__ || string.length == 0 || [string hasSuffix:@"/"]) return string.copy;
    return [string stringByAppendingFormat:@"@%@x", @(scale)];
}

/**
 Return the path scale.
 
 e.g.
 <table>
 <tr><th>Path            </th><th>Scale </th></tr>
 <tr><td>"icon.png"      </td><td>1     </td></tr>
 <tr><td>"icon@2x.png"   </td><td>2     </td></tr>
 <tr><td>"icon@2.5x.png" </td><td>2.5   </td></tr>
 <tr><td>"icon@2x"       </td><td>1     </td></tr>
 <tr><td>"icon@2x..png"  </td><td>1     </td></tr>
 <tr><td>"icon@2x.png/"  </td><td>1     </td></tr>
 </table>
 */
static CGFloat _NSStringPathScale(NSString *string) {
    if (string.length == 0 || [string hasSuffix:@"/"]) return 1;
    NSString *name = string.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    [pattern enumerateMatchesInString:name options:kNilOptions range:NSMakeRange(0, name.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location >= 3) {
            scale = [string substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)].doubleValue;
        }
    }];
    
    return scale;
}


@implementation YYImage {
    YYImageDecoder *_decoder;
    NSArray *_preloadedFrames;
    dispatch_semaphore_t _preloadedLock;
    NSUInteger _bytesPerFrame;
}

+ (YYImage *)imageNamed:(NSString *)name {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return nil;
    
    NSString *res = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSString *path = nil;
    CGFloat scale = 1;
    
    // If no extension, guess by system supported (same as UIImage).
    NSArray *exts = ext.length > 0 ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng"];
    NSArray *scales = _NSBundlePreferredScales();
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = _NSStringByAppendingNameScale(res, scale);
        for (NSString *e in exts) {
            path = [[NSBundle mainBundle] pathForResource:scaledName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    if (path.length == 0) return nil;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) return nil;
    
    return [[self alloc] initWithData:data scale:scale];
}

+ (YYImage *)imageWithContentsOfFile:(NSString *)path {
    return [[self alloc] initWithContentsOfFile:path];
}

+ (YYImage *)imageWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

+ (YYImage *)imageWithData:(NSData *)data scale:(CGFloat)scale {
    return [[self alloc] initWithData:data scale:scale];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self initWithData:data scale:_NSStringPathScale(path)];
}

- (instancetype)initWithData:(NSData *)data {
    return [self initWithData:data scale:1];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    if (data.length == 0) return nil;
    if (scale <= 0) scale = [NSScreen mainScreen].backingScaleFactor;
    _preloadedLock = dispatch_semaphore_create(1);
    @autoreleasepool {
        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:data scale:scale];
        YYImageFrame *frame = [decoder frameAtIndex:0 decodeForDisplay:YES];
        NSImage *image = frame.image;
        if (!image) return nil;
        CGImageRef cgImage;
        
        // 根据图片旋转方向，恢复图片
        int imageOrient = [YYImage imageOrientationForImageData:data];
        if(imageOrient != kCGImagePropertyOrientationUp) {
            CGImageRef orImage = [image cgImageRef];
            cgImage = [YYImage processImage:orImage
                            withOrientation:imageOrient];
            CFRelease(orImage);
        } else {
            cgImage = [image cgImageRef];
        }
        
        CGSize size = CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
        self = [self initWithCGImage:cgImage size:size];
        /* self = [self initWithCGImage:cgImage scale:decoder.scale orientation:image.imageOrientation]; */
        if (!self) return nil;
        _animatedImageType = decoder.type;
        if (decoder.frameCount > 1) {
            _decoder = decoder;
            _bytesPerFrame = CGImageGetBytesPerRow(cgImage) * CGImageGetHeight(cgImage);
            _animatedImageMemorySize = _bytesPerFrame * decoder.frameCount;
        }
        self.yy_isDecodedForDisplay = YES;
    }
    return self;
}

- (NSData *)animatedImageData {
    return _decoder.data;
}

- (void)setPreloadAllAnimatedImageFrames:(BOOL)preloadAllAnimatedImageFrames {
    if (_preloadAllAnimatedImageFrames != preloadAllAnimatedImageFrames) {
        if (preloadAllAnimatedImageFrames && _decoder.frameCount > 0) {
            NSMutableArray *frames = [NSMutableArray new];
            for (NSUInteger i = 0, max = _decoder.frameCount; i < max; i++) {
                NSImage *img = [self animatedImageFrameAtIndex:i];
                if (img) {
                    [frames addObject:img];
                } else {
                    [frames addObject:[NSNull null]];
                }
            }
            dispatch_semaphore_wait(_preloadedLock, DISPATCH_TIME_FOREVER);
            _preloadedFrames = frames;
            dispatch_semaphore_signal(_preloadedLock);
        } else {
            dispatch_semaphore_wait(_preloadedLock, DISPATCH_TIME_FOREVER);
            _preloadedFrames = nil;
            dispatch_semaphore_signal(_preloadedLock);
        }
    }
}

#pragma mark - protocol NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSNumber *scale = [aDecoder decodeObjectForKey:@"YYImageScale"];
    NSData *data = [aDecoder decodeObjectForKey:@"YYImageData"];
    if (data.length) {
        self = [self initWithData:data scale:scale.doubleValue];
    } else {
        self = [super initWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (_decoder.data.length) {
        [aCoder encodeObject: @1 /* TODO @(self.scale) */ forKey:@"YYImageScale"];
        [aCoder encodeObject:_decoder.data forKey:@"YYImageData"];
    } else {
        [super encodeWithCoder:aCoder]; // Apple use UIImagePNGRepresentation() to encode UIImage.
    }
}

#pragma mark - protocol YYAnimatedImage

- (NSUInteger)animatedImageFrameCount {
    return _decoder.frameCount;
}

- (NSUInteger)animatedImageLoopCount {
    return _decoder.loopCount;
}

- (NSUInteger)animatedImageBytesPerFrame {
    return _bytesPerFrame;
}

- (NSImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    if (index >= _decoder.frameCount) return nil;
    dispatch_semaphore_wait(_preloadedLock, DISPATCH_TIME_FOREVER);
    NSImage *image = _preloadedFrames[index];
    dispatch_semaphore_signal(_preloadedLock);
    if (image) return image == (id)[NSNull null] ? nil : image;
    return [_decoder frameAtIndex:index decodeForDisplay:YES].image;
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    NSTimeInterval duration = [_decoder frameDurationAtIndex:index];
    
    /*
     http://opensource.apple.com/source/WebCore/WebCore-7600.1.25/platform/graphics/cg/ImageSourceCG.cpp
     Many annoying ads specify a 0 duration to make an image flash as quickly as 
     possible. We follow Safari and Firefox's behavior and use a duration of 100 ms 
     for any frames that specify a duration of <= 10 ms.
     See <rdar://problem/7689300> and <http://webkit.org/b/36082> for more information.
     
     See also: http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser.
     */
    if (duration < 0.011f) return 0.100f;
    return duration;
}

+ (int) imageOrientationForImageData: (NSData*) data {
    int orient = 1;
    CGImageSourceRef is = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if(is != NULL) {
        CFDictionaryRef dict = CGImageSourceCopyPropertiesAtIndex(is, 0, NULL);
        if(dict != NULL) {
            CFNumberRef imageOrientation;
            if (CFDictionaryGetValueIfPresent(dict, kCGImagePropertyOrientation,
                                              (const void **)&imageOrientation)) {
                if(imageOrientation) {
                    CFNumberGetValue(imageOrientation, kCFNumberIntType, &orient);
                    CFRelease(imageOrientation);
                }
            }
            CFRelease(dict);
        }
        CFRelease(is);
    }
    return orient;
}

// 根据图片旋转方向，恢复原图
+ (_Nullable CGImageRef) processImage:(_Nullable CGImageRef) imageRef
                      withOrientation:(int) imageOrientation {
    if (imageRef != NULL) {
        // 获取图片信息
        CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
        if (colorSpace != NULL) {
            double degreesToRotate = 0.0;
            BOOL swapWidthHeight = NO;
            BOOL mirrored = NO;
            // 根据旋转方向获得绘制的参数
            switch (imageOrientation) {
                case kCGImagePropertyOrientationUp:
                degreesToRotate = 0.0;
                swapWidthHeight = NO;
                mirrored = NO;
                break;
                case kCGImagePropertyOrientationUpMirrored:
                degreesToRotate = 0.0;
                swapWidthHeight = NO;
                mirrored = YES;
                break;
                case kCGImagePropertyOrientationRight:
                degreesToRotate = 90.0;
                swapWidthHeight = YES;
                mirrored = NO;
                break;
                case kCGImagePropertyOrientationRightMirrored:
                degreesToRotate = 90.0;
                swapWidthHeight = YES;
                mirrored = YES;
                break;
                case kCGImagePropertyOrientationDown:
                degreesToRotate = 180.0;
                swapWidthHeight = NO;
                mirrored = NO;
                break;
                case kCGImagePropertyOrientationDownMirrored:
                degreesToRotate = 180.0;
                swapWidthHeight = NO;
                mirrored = YES;
                break;
                case kCGImagePropertyOrientationLeft:
                degreesToRotate = -90.0;
                swapWidthHeight = YES;
                mirrored = NO;
                break;
                case kCGImagePropertyOrientationLeftMirrored:
                degreesToRotate = -90.0;
                swapWidthHeight = YES;
                mirrored = YES;
                break;
            }
            
            return [YYImage rotate:imageRef withDegree:degreesToRotate mirror:mirrored];
        }
    }
    return NULL;
}

+ (_Nullable CGImageRef) rotate:(_Nullable CGImageRef) imageRef
                     withDegree:(int) degree mirror: (BOOL) mirrored {
    if (imageRef == NULL) return NULL;
    
    BOOL swapWidthHeight = (degree % 180 != 0);
    // get bitmap info
    size_t originalWidth = CGImageGetWidth(imageRef);
    size_t originalHeight = CGImageGetHeight(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    double radians = degree * M_PI / 180.0;

    // swap width and height
    size_t width, height;
    if (swapWidthHeight) {
        width = originalHeight;
        height = originalWidth;
        // calculate new bytes per row
        bytesPerRow = originalHeight * (bytesPerRow / originalWidth);
    } else {
        width = originalWidth;
        height = originalHeight;
    }
    
    // redraw image into Context
    CGImageRef orientedImage = nil;
    CGContextRef contextRef = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    if(contextRef != NULL)  {
        float halfWidth = ((float) width) / 2;
        float halfHeight = ((float) height) / 2;
        CGContextTranslateCTM(contextRef, halfWidth, halfHeight);
        if (mirrored) { CGContextScaleCTM(contextRef, -1.0, 1.0); }
        CGContextRotateCTM(contextRef, radians);
        if (swapWidthHeight) {
            CGContextTranslateCTM(contextRef, -halfHeight, -halfWidth);
        } else {
            CGContextTranslateCTM(contextRef, -halfWidth, -halfHeight);
        }
        CGRect imageRect = CGRectMake(0, 0, originalWidth, originalHeight);
        CGContextDrawImage(contextRef, imageRect, imageRef);
        orientedImage = CGBitmapContextCreateImage(contextRef);
        CGContextRelease(contextRef);
    }
    return orientedImage;
}
@end
