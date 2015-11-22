//
//  OSAHash.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 10/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSCategories.h"
#import "OSFastGraphics.h"
#import "OSAHash.h"

static const NSUInteger OSAHashImageWidthInPixels = 8;
static const NSUInteger OSAhashImageHeightInPixels = 8;
static const OSHashDistanceType OSAHashDistanceThreshold = 10;

@implementation OSAHash

#pragma mark - OSImageHashing Protocol

- (OSHashType)hashImageData:(NSData *)imageData
{
    NSAssert(imageData, @"Image data must not be null");
    unsigned char *pixels = [imageData RGBABitmapDataForResizedImageWithWidth:OSAHashImageWidthInPixels
                                                                    andHeight:OSAhashImageHeightInPixels];
    OSHashType result = ahash_rgba_8_8(pixels);
    return result;
}

- (OSHashDistanceType)hashDistanceSimilarityThreshold
{
    return OSAHashDistanceThreshold;
}

@end
