//
//  OSPHash.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 10/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSCategories.h"
#import "OSFastGraphics.h"
#import "OSPHash.h"

static const NSUInteger OSPHashImageWidthInPixels = 32;
static const NSUInteger OSPhashImageHeightInPixels = 32;
static const OSHashDistanceType OSPHashDistanceThreshold = 10;

@implementation OSPHash

#pragma mark - OSImageHashingProvider

- (OSHashType)hashImageData:(NSData *)imageData
{
    NSAssert(imageData, @"Image data must not be null");
    unsigned char *pixels = [imageData RGBABitmapDataForResizedImageWithWidth:OSPHashImageWidthInPixels
                                                                    andHeight:OSPhashImageHeightInPixels];
    double greyscalePixels[OSPHashImageWidthInPixels][OSPhashImageHeightInPixels] = {{0.0}};
    double dctPixels[OSPHashImageWidthInPixels][OSPhashImageHeightInPixels] = {{0.0}};
    greyscale_pixels_rgba_32_32(pixels, greyscalePixels);
    fast_dct_rgba_32_32(greyscalePixels, dctPixels);
    double dctAverage = fast_avg_no_first_el_rgba_8_8(dctPixels);
    OSHashType result = phash_rgba_8_8(dctPixels, dctAverage);
    return result;
}

- (OSHashDistanceType)hashDistanceSimilarityThreshold
{
    return OSPHashDistanceThreshold;
}

@end
