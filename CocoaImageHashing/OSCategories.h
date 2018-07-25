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

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (CocoaImageHashing)

- (NSArray<OSTuple<id, id> *> *)arrayWithPairCombinations;

- (void)enumeratePairCombinationsUsingBlock:(void (^)(id __unsafe_unretained leftHand, id __unsafe_unretained rightHand))block;

@end

NS_ASSUME_NONNULL_END

#pragma mark - NSData Category

NS_ASSUME_NONNULL_BEGIN

@interface NSData (CococaImageHashing)

- (nullable NSData *)RGBABitmapDataForResizedImageWithWidth:(NSUInteger)width
                                                  andHeight:(NSUInteger)height;

@end

NS_ASSUME_NONNULL_END

#pragma mark - NSBitmapImagerep Category

#if !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

NS_ASSUME_NONNULL_BEGIN

@interface NSBitmapImageRep (CocoaImageHashing)

+ (NSBitmapImageRep *)imageRepFrom:(NSBitmapImageRep *)sourceImageRep
                     scaledToWidth:(NSUInteger)width
                    scaledToHeight:(NSUInteger)height
                usingInterpolation:(NSImageInterpolation)imageInterpolation;

@end

NS_ASSUME_NONNULL_END

#endif

#pragma mark - NSImage Category

#if !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (CocoaImageHashing)

- (nullable NSData *)dataRepresentation;

@end

NS_ASSUME_NONNULL_END

#endif

#pragma mark - UIImage Category

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CocoaImageHashing)

- (nullable NSData *)dataRepresentation;

@end

NS_ASSUME_NONNULL_END

#endif

#pragma mark - NSString Category

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CocoaImageHashing)

- (unsigned long long)fileSizeOfElementInBundle:(NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END
