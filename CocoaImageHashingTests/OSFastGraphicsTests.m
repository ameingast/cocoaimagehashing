//
//  OSFastGraphicsTests.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 15/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSCategories.h"
#import "OSFastGraphics.h"
#import "OSImageHashingBaseTest.h"

@interface OSFastGraphicsTests : OSImageHashingBaseTest

@end

@implementation OSFastGraphicsTests

- (void)testDCT
{
    NSData *imageData = [self loadImageAsData:@"blurred/architecture1.bmp"];
    unsigned char *pixels = [imageData RGBABitmapDataForResizedImageWithWidth:32
                                                                    andHeight:32];
    double greyscalePixels[32][32] = {{0.0}};
    double fastDctPixels[32][32] = {{0.0}};
    double dctPixels[32][32] = {{0.0}};
    greyscale_pixels_rgba_32_32(pixels, greyscalePixels);
    dct_rgba_32_32(greyscalePixels, dctPixels);
    fast_dct_rgba_32_32(greyscalePixels, fastDctPixels);
    for (NSUInteger i = 0; i < 32; i++) {
        for (NSUInteger j = 0; j < 32; j++) {
            XCTAssertEqual(dctPixels[i][j], fastDctPixels[i][j], @"DCT mismatch at: %@ %@", @(i), @(j));
        }
    }
}

- (void)testFastDCTMultithreadedPerformance
{
    const NSUInteger iterations = 1024 * 2;
    NSData *imageData = [self loadImageAsData:@"blurred/architecture1.bmp"];
    unsigned char *pixels = [imageData RGBABitmapDataForResizedImageWithWidth:32
                                                                    andHeight:32];
    double fastDctPixels[32][32] = {{0.0}};
    double greyscalePixels[32][32] = {{0.0}};
    greyscale_pixels_rgba_32_32(pixels, greyscalePixels);
    NSDate *t0 = [NSDate date];
    for (NSUInteger i = 0; i < iterations; i++) {
        fast_dct_rgba_32_32(greyscalePixels, fastDctPixels);
    }
    NSDate *t1 = [NSDate date];
    NSTimeInterval executionTime = [t1 timeIntervalSinceDate:t0];
    NSUInteger MBs = (iterations * 32 * 32 * sizeof(double)) / 1024 / 1024;
    NSLog(@"DCT processing %@ MB/s", @(MBs / executionTime));
}

@end
