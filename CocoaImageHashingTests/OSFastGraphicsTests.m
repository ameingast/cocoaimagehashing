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

- (void)testRotateMatrix
{
    unsigned char pixels[] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    unsigned char result[] = {3, 6, 9, 2, 5, 8, 1, 4, 7};
    rotate_matrix(pixels, 3);
    for (int i = 0; i < 9; i++) {
        XCTAssertEqual(pixels[i], result[i]);
    }
}

- (void)testRotateMatrix9x9
{
    unsigned char pixels[9 * 9] = {0};
    unsigned char result[9 * 9] = {0};
    for (unsigned char i = 0; i < 9 * 9; i++) {
        pixels[i] = i;
        result[i] = i;
    }
    for (unsigned char i = 0; i < 9 * 9; i++) {
        XCTAssertEqual(pixels[i], result[i]);
    }
    rotate_matrix_9_9(pixels);
    rotate_matrix(result, 9);
    for (unsigned char i = 0; i < 9 * 9; i++) {
        XCTAssertEqual(pixels[i], result[i]);
    }
}

- (void)testRotateMatrixPerformance
{
    const NSUInteger iterations = 1024 * 1024 * 64;
    unsigned char pixels[9 * 9] = {0};
    for (unsigned char i = 0; i < 9 * 9; i++) {
        pixels[i] = i;
    }
    NSDate *t0 = [NSDate date];
    for (NSUInteger i = 0; i < iterations; i++) {
        rotate_matrix(pixels, 9);
    }
    NSDate *t1 = [NSDate date];
    NSTimeInterval executionTime = [t1 timeIntervalSinceDate:t0];
    double MBs = (iterations * 9 * 9 * sizeof(unsigned char)) / 1024. / 1024.;
    NSLog(@"Matrix rotation processing %@ MB/s", @(MBs / executionTime));
}

- (void)testRotateMatrixPerformanceFast
{
    const NSUInteger iterations = 1024 * 1024 * 64;
    unsigned char pixels[9 * 9] = {0};
    for (unsigned char i = 0; i < 9 * 9; i++) {
        pixels[i] = i;
    }
    NSDate *t0 = [NSDate date];
    for (NSUInteger i = 0; i < iterations; i++) {
        rotate_matrix_9_9(pixels);
    }
    NSDate *t1 = [NSDate date];
    NSTimeInterval executionTime = [t1 timeIntervalSinceDate:t0];
    double MBs = (iterations * 9 * 9 * sizeof(unsigned char)) / 1024. / 1024.;
    NSLog(@"Fast Matrix rotation processing %@ MB/s", @(MBs / executionTime));
}

- (void)testRotateRGBAMatrix
{
    unsigned char pixels[9 * 9 * 4] = {0};
    unsigned char result[9 * 9 * 4] = {0};
    unsigned int cnt = 0;
    for (int i = 0; i < 9 * 9; i++) {
        unsigned char value = i % 255;
        pixels[cnt++] = value;
        pixels[cnt++] = value;
        pixels[cnt++] = value;
        pixels[cnt++] = value;
    }
    memcpy(&pixels, &result, 9 * 9 * 4 * sizeof(unsigned char));
    rotate_rgba_matrix_9_9(pixels);
    rotate_rgba_matrix_9_9(pixels);
    rotate_rgba_matrix_9_9(pixels);
    rotate_rgba_matrix_9_9(pixels);
    for (int i = 0; i < 9 * 9 * 4; i++) {
        XCTAssertEqual(pixels[i], result[i]);
    }
}
- (void)testRotateRGBAMatrixPerformance
{
    const NSUInteger iterations = 1024 * 1024 * 4;
    unsigned char pixels[9 * 9 * 4] = {0};
    unsigned int cnt = 0;
    for (int i = 0; i < 9 * 9; i++) {
        unsigned char value = i % 255;
        pixels[cnt++] = value;
        pixels[cnt++] = value;
        pixels[cnt++] = value;
        pixels[cnt++] = value;
    }
    NSDate *t0 = [NSDate date];
    for (NSUInteger i = 0; i < iterations; i++) {
        rotate_rgba_matrix_9_9(pixels);
    }
    NSDate *t1 = [NSDate date];
    NSTimeInterval executionTime = [t1 timeIntervalSinceDate:t0];
    double MBs = (iterations * 9 * 9 * 4 * sizeof(unsigned char)) / 1024. / 1024.;
    NSLog(@"Fast Matrix RGBA rotation processing %@ MB/s", @(MBs / executionTime));
}

- (void)testDCT
{
    NSData *imageData = [self loadImageAsData:@"blurred/architecture1.bmp"];
    NSData *pixels = [imageData RGBABitmapDataForResizedImageWithWidth:8
                                                             andHeight:8];
    double greyscalePixels[32][32] = {{0.0}};
    double fastDctPixels[32][32] = {{0.0}};
    double dctPixels[32][32] = {{0.0}};
    greyscale_pixels_rgba_32_32([pixels bytes], greyscalePixels);
    dct_rgba_32_32(greyscalePixels, dctPixels);
    fast_dct_rgba_32_32(greyscalePixels, fastDctPixels);
    for (NSUInteger i = 0; i < 32; i++) {
        for (NSUInteger j = 0; j < 32; j++) {
            XCTAssertTrue(fabs(dctPixels[i][j] - fastDctPixels[i][j]) < 0.00000001,
                          @"DCT mismatch at: %@ %@", @(i), @(j));
        }
    }
}

- (void)testFastDCTMultithreadedPerformance
{
    const NSUInteger iterations = 1024 * 2;
    NSData *imageData = [self loadImageAsData:@"blurred/architecture1.bmp"];
    NSData *pixels = [imageData RGBABitmapDataForResizedImageWithWidth:8
                                                             andHeight:8];
    double fastDctPixels[32][32] = {{0.0}};
    double greyscalePixels[32][32] = {{0.0}};
    greyscale_pixels_rgba_32_32([pixels bytes], greyscalePixels);
    NSDate *t0 = [NSDate date];
    for (NSUInteger i = 0; i < iterations; i++) {
        fast_dct_rgba_32_32(greyscalePixels, fastDctPixels);
    }
    NSDate *t1 = [NSDate date];
    NSTimeInterval executionTime = [t1 timeIntervalSinceDate:t0];
    double MBs = (iterations * 32 * 32 * sizeof(double)) / 1024. / 1024.;
    NSLog(@"DCT processing %@ MB/s", @(MBs / executionTime));
}

- (void)testResizedRGBABitmapDataScanline
{
    NSData *imageData = [self loadImageAsData:@"misc/latrobe.bmp"];
    for (NSUInteger dim = 8; dim <= 9; dim++) {
        NSData *pixels = [imageData RGBABitmapDataForResizedImageWithWidth:dim
                                                                 andHeight:dim];
        uint64_t *lines = (uint64_t *)[pixels bytes];
        NSUInteger length = [pixels length] / sizeof(lines);
        for (NSUInteger i = 0; i < length; i += 8) {
            XCTAssertNotEqual(lines[i], (uint64_t)0);
            XCTAssertNotEqual(lines[i + 1], (uint64_t)0);
            XCTAssertNotEqual(lines[i + 2], (uint64_t)0);
            XCTAssertNotEqual(lines[i + 3], (uint64_t)0);
            XCTAssertNotEqual(lines[i + 4], (uint64_t)0);
        }
    }
}

@end
