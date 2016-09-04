//
//  OSCategories.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 11/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSCategories.h"
#import "OSTypes.h"

#pragma mark - NSArray Category

@implementation NSArray (CocoaImageHashing)

- (NSArray<OSTuple<id, id> *> *)arrayWithPairCombinations
{
    NSArray<OSTuple<id, id> *> *result = [self arrayWithPairCombinations:^BOOL(id leftHand, id rightHand) {
      OS_MARK_UNUSED(leftHand);
      OS_MARK_UNUSED(rightHand);
      return YES;
    }];
    return result;
}

- (NSArray<OSTuple<id, id> *> *)arrayWithPairCombinations:(BOOL (^)(id leftHand, id rightHand))matcher
{
    NSMutableArray<OSTuple<id, id> *> *pairs = [NSMutableArray new];
    [self arrayWithPairCombinations:matcher
                  withResultHandler:^(id leftHand, id rightHand) {
                    OSTuple<id, id> *tuple = [OSTuple tupleWithFirst:leftHand
                                                           andSecond:rightHand];
                    [pairs addObject:tuple];
                  }];
    return pairs;
}

- (void)arrayWithPairCombinations:(BOOL (^)(id leftHand, id rightHand))matcher
                withResultHandler:(void (^)(id leftHand, id rightHand))resultHandler
{
    for (NSUInteger i = 0; i < [self count] - 1; i++) {
        for (NSUInteger j = i + 1; j < [self count]; j++) {
            BOOL result = matcher(self[i], self[j]);
            if (result) {
                resultHandler(self[i], self[j]);
            }
        }
    }
}

@end

#pragma mark - NSData Category

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@implementation NSData (CocoaImageHashing)

- (NSData *)RGBABitmapDataForResizedImageWithWidth:(NSUInteger)width
                                         andHeight:(NSUInteger)height
{
    UIImage *baseImage = [UIImage imageWithData:self];
    if (!baseImage) {
        return nil;
    }
    CGImageRef imageRef = [baseImage CGImage];
    if (!imageRef) {
        return nil;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableData *data = [NSMutableData dataWithLength:height * width * 4];
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate([data mutableBytes], width, height, bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, rect, imageRef);
    CGContextRelease(context);
    return data;
}

@end

#else

@implementation NSData (CocoaImageHashing)

- (NSData *)RGBABitmapDataForResizedImageWithWidth:(NSUInteger)width
                                         andHeight:(NSUInteger)height
{
    NSBitmapImageRep *sourceImageRep = [NSBitmapImageRep imageRepWithData:self];
    if (!sourceImageRep) {
        return nil;
    }
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepFrom:sourceImageRep
                                                  scaledToWidth:(NSInteger)width
                                                 scaledToHeight:(NSInteger)height
                                             usingInterpolation:NSImageInterpolationHigh];
    if (!imageRep) {
        return nil;
    }
    unsigned char *pixels = [imageRep bitmapData];
    NSData *result = [NSData dataWithBytes:pixels
                                    length:OS_ALIGN(4 * width, 64) * height];
    return result;
}

@end

#endif

#pragma mark - NSBitmapImageRep Category

#if !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@implementation NSBitmapImageRep (CocoaImageHashing)

+ (NSBitmapImageRep *)imageRepFrom:(NSBitmapImageRep *)sourceImageRep
                     scaledToWidth:(NSInteger)width
                    scaledToHeight:(NSInteger)height
                usingInterpolation:(NSImageInterpolation)imageInterpolation
{
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                         pixelsWide:width
                                                                         pixelsHigh:height
                                                                      bitsPerSample:8
                                                                    samplesPerPixel:4
                                                                           hasAlpha:YES
                                                                           isPlanar:NO
                                                                     colorSpaceName:NSCalibratedRGBColorSpace
                                                                        bytesPerRow:OS_ALIGN(4 * width, 64) // multiple of 64 bytes to improve CG performance
                                                                       bitsPerPixel:0];
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
    context.imageInterpolation = imageInterpolation;
    [NSGraphicsContext setCurrentContext:context];
    [sourceImageRep drawInRect:NSMakeRect(0, 0, width, height)];
    [context flushGraphics];
    [NSGraphicsContext restoreGraphicsState];
    [imageRep setSize:NSMakeSize(width, height)];
    return imageRep;
}

@end

#endif

#pragma mark - NSImage Category

#if !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@implementation NSImage (CocoaImageHashing)

- (NSData *)dataRepresentation
{
    NSData *result = [self TIFFRepresentation];
    return result;
}

@end

#endif

#pragma mark - UIImage Category

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@implementation UIImage (CocoaImageHashing)

- (NSData *)dataRepresentation
{
    NSData *result = UIImagePNGRepresentation(self);
    return result;
}

@end

#endif

#pragma mark - NSString Category

@implementation NSString (CocoaImageHashing)

- (unsigned long long)fileSizeOfElementInBundle:(NSBundle *)bundle
{
    NSString *path = [bundle pathForResource:[self stringByDeletingPathExtension]
                                      ofType:[self pathExtension]];
    NSDictionary<NSString *, id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                                error:nil];
    NSNumber *fileSizeNumber = attributes[@"NSFileSize"];
    unsigned long long result = [fileSizeNumber unsignedLongLongValue];
    return result;
}

@end