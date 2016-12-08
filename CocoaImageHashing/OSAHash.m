//
//  OSAHash.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 10/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSAHash.h"
#import "OSCategories.h"
#import "OSFastGraphics.h"

static const NSUInteger OSAHashImageWidthInPixels = 8;
static const NSUInteger OSAHashImageHeightInPixels = 8;
static const OSHashDistanceType OSAHashDistanceThreshold = 10;

@implementation OSAHash

#pragma mark - OSImageHashing Protocol

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (OSHashType)hashImageData:(NSData *)imageData
{
    NSAssert(imageData, @"Image data must not be null");
    NSData *pixels = [imageData RGBABitmapDataForResizedImageWithWidth:OSAHashImageWidthInPixels
                                                             andHeight:OSAHashImageHeightInPixels];
    if (!pixels) {
        return OSHashTypeError;
    }
    OSHashType result = ahash_rgba_8_8([pixels bytes]);
    return result;
}

- (OSHashDistanceType)hashDistanceSimilarityThreshold
{
    return OSAHashDistanceThreshold;
}

@end
