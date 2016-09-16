//
//  OSPHashTests.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 11/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSImageHashingBaseTest.h"

@interface OSPHashTests : OSImageHashingBaseTest

@end

@implementation OSPHashTests

- (void)testPHashOnEqualImages
{
    [self assertHashDistanceEqual:@"blurred/architecture1.bmp"
                rightHandImageName:@"blurred/architecture1.bmp"
        withImageHashingProviderId:OSImageHashingProviderPHash];
}

- (void)testPHashOnSimilarImages
{
    [self assertHashImagesSimilar:@"blurred/architecture1.bmp"
                rightHandImageName:@"compressed/architecture1.jpg"
        withImageHashingProviderId:OSImageHashingProviderPHash];
}

- (void)testPHashOnDifferingImages
{
    [self assertHashImagesNotSimilar:@"blurred/architecture1.bmp"
                  rightHandImageName:@"blurred/bamarket115.bmp"
          withImageHashingProviderId:OSImageHashingProviderPHash];
}

- (void)testImageSimilarityOnPHash
{
    NSArray<NSArray<OSDataHolder *> *> *dataSet = [self similarImages];
    NSUInteger baseCount = [dataSet count];
    NSUInteger combinations = [dataSet count] * [dataSet count] - [dataSet count];
    NSLog(@"Testing %@ base images for %@ combinations", @(baseCount), @(combinations));
    for (NSArray<OSDataHolder *> *dataArray in dataSet) {
        NSArray<OSTuple<OSDataHolder *, OSDataHolder *> *> *pairs = [dataArray arrayWithPairCombinations];
        for (OSTuple<OSDataHolder *, OSDataHolder *> *pair in pairs) {
            BOOL phashResult = [[OSImageHashing sharedInstance] compareImageData:OS_CAST_NONNULL(pair.first.data)
                                                                              to:OS_CAST_NONNULL(pair.second.data)
                                                                  withProviderId:OSImageHashingProviderPHash];
            XCTAssertTrue(phashResult, @"Images should match with pHash: %@ - %@", pair.first.name, pair.second.name);
        }
    }
}

- (void)testImageDiversityOnPHash
{
    NSArray<OSTuple<OSDataHolder *, OSDataHolder *> *> *dataSet = [self diverseImages];
    NSUInteger baseCount = [dataSet count];
    NSLog(@"Testing %@  combinations", @(baseCount));
    for (OSTuple<OSDataHolder *, OSDataHolder *> *pair in dataSet) {
        BOOL result = [[OSImageHashing sharedInstance] compareImageData:OS_CAST_NONNULL(pair.first.data)
                                                                     to:OS_CAST_NONNULL(pair.second.data)
                                                         withProviderId:OSImageHashingProviderPHash];
        XCTAssertFalse(result, @"Images should not match: %@ - %@", pair.first.name, pair.second.name);
    }
}

- (void)testPHashMultithreadedHashingPerformance
{
    const NSUInteger iterations = 1024 * 2;
    unsigned long long filesize = [@"blurred/architecture1.bmp" fileSizeOfElementInBundle:[self bundle]];
    NSData *imageData = [self loadImageAsData:@"blurred/architecture1.bmp"];
    NSDate *t0 = [NSDate date];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = (NSInteger)[[NSProcessInfo processInfo] processorCount] * 2;
    for (NSUInteger i = 0; i < iterations; i++) {
        [operationQueue addOperationWithBlock:^{
          [self.pHash hashImageData:imageData];
        }];
    }
    [operationQueue waitUntilAllOperationsAreFinished];
    NSDate *t1 = [NSDate date];
    NSTimeInterval executionTime = [t1 timeIntervalSinceDate:t0];
    unsigned long long hashedMBs = filesize * iterations / 1024 / 1024;
    double hashMBsPerS = hashedMBs / executionTime;
    NSLog(@"Hashing image data @ %@ MB/s", @(hashMBsPerS));
}

- (void)testDataHashingWithMalformedInput
{
    NSData *data = [NSMutableData dataWithLength:1024 * 1024];
    OSHashType result = [self.pHash hashImageData:data];
    XCTAssertEqual(OSHashTypeError, result);
}

@end