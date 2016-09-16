//
//  OSCategories.h
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 11/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

@import UIKit;

#endif

#if !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@import Cocoa;

#endif

@class OSTuple<A, B>;

@class OSWeakTuple<A, B>;

#pragma mark - NSArray Category

@interface NSArray (CocoaImageHashing)

NS_ASSUME_NONNULL_BEGIN

- (NSArray<OSTuple<id, id> *> *)arrayWithPairCombinations;

- (void)enumeratePairCombinationsUsingBlock:(void (^)(id __unsafe_unretained leftHand, id __unsafe_unretained rightHand))block;

NS_ASSUME_NONNULL_END

@end

#pragma mark - NSData Category

@interface NSData (CococaImageHashing)

NS_ASSUME_NONNULL_BEGIN

- (nullable NSData *)RGBABitmapDataForResizedImageWithWidth:(NSUInteger)width
                                                  andHeight:(NSUInteger)height;

@end

NS_ASSUME_NONNULL_END

#pragma mark - NSBitmapImagerep Category

#if !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@interface NSBitmapImageRep (CocoaImageHashing)

NS_ASSUME_NONNULL_BEGIN

+ (NSBitmapImageRep *)imageRepFrom:(NSBitmapImageRep *)sourceImageRep
                     scaledToWidth:(NSUInteger)width
                    scaledToHeight:(NSUInteger)height
                usingInterpolation:(NSImageInterpolation)imageInterpolation;

NS_ASSUME_NONNULL_END

@end

#endif

#pragma mark - NSImage Category

#if !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@interface NSImage (CocoaImageHashing)

NS_ASSUME_NONNULL_BEGIN

- (nullable NSData *)dataRepresentation;

NS_ASSUME_NONNULL_END

@end

#endif

#pragma mark - UIImage Category

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@interface UIImage (CocoaImageHashing)

NS_ASSUME_NONNULL_BEGIN

- (nullable NSData *)dataRepresentation;

NS_ASSUME_NONNULL_END

@end

#endif

#pragma mark - NSString Category

@interface NSString (CocoaImageHashing)

NS_ASSUME_NONNULL_BEGIN

- (unsigned long long)fileSizeOfElementInBundle:(NSBundle *)bundle;

NS_ASSUME_NONNULL_END

@end
