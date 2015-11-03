//
//  OSDHashTests.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 10/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSImageHashingBaseTest.h"

@interface OSDHashTests : OSImageHashingBaseTest

@end

@implementation OSDHashTests

- (void)testDHashOnEqualImages
{
    [self assertHashDistanceEqual:@"blurred/architecture1.bmp"
                rightHandImageName:@"blurred/architecture1.bmp"
        withImageHashingProviderId:OSImageHashingProviderDHash];
}

- (void)testDHashOnSimilarImages
{
    [self assertHashImagesSimilar:@"blurred/architecture1.bmp"
                rightHandImageName:@"compressed/architecture1.jpg"
        withImageHashingProviderId:OSImageHashingProviderDHash];
}

- (void)testDHashOnDifferingImages
{
    [self assertHashImagesNotSimilar:@"blurred/architecture1.bmp"
                  rightHandImageName:@"blurred/bamarket115.bmp"
          withImageHashingProviderId:OSImageHashingProviderDHash];
}

- (void)testDHashOnDifferingImagesRegression
{
    [self assertHashImagesNotSimilar:@"blurred/Tower-Bridge-at-night--London--England_web.bmp"
                  rightHandImageName:@"blurred/architecture1.bmp"
          withImageHashingProviderId:OSImageHashingProviderDHash];
    [self assertHashImagesNotSimilar:@"blurred/Hhirst_BGE.bmp"
                  rightHandImageName:@"blurred/latrobe.bmp"
          withImageHashingProviderId:OSImageHashingProviderDHash];
    [self assertHashImagesNotSimilar:@"blurred/Tower-Bridge-at-night--London--England_web.bmp"
                  rightHandImageName:@"blurred/targetjasperjohns.bmp"
          withImageHashingProviderId:OSImageHashingProviderDHash];
    [self assertHashImagesNotSimilar:@"blurred/damien_hirst_does_fashion_week.bmp"
                  rightHandImageName:@"blurred/johns_portrait_380x311.bmp"
          withImageHashingProviderId:OSImageHashingProviderDHash];
    [self assertHashImagesNotSimilar:@"blurred/dhirst_a3b9ddea.bmp"
                  rightHandImageName:@"blurred/latrobe.bmp"
          withImageHashingProviderId:OSImageHashingProviderDHash];
    [self assertHashImagesNotSimilar:@"blurred/diamondskull.bmp"
                  rightHandImageName:@"blurred/targetjasperjohns.bmp"
          withImageHashingProviderId:OSImageHashingProviderDHash];
}

- (void)testPerformanceDHash
{
    NSData *imageData = [self loadImageAsData:@"blurred/architecture1.bmp"];
    [self measureBlock:^{
      for (int i = 0; i < 256; i++) {
          [self.dHash hashImageData:imageData];
      }
    }];
}

- (void)testdHashMultithreadedHashingPerformance
{
    const NSUInteger iterations = 1024 * 8;
    unsigned long long filesize = [@"blurred/architecture1.bmp" fileSizeOfElementInBundle:[self bundle]];
    NSData *imageData = [self loadImageAsData:@"blurred/architecture1.bmp"];
    NSDate *t0 = [NSDate date];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = (NSInteger)[[NSProcessInfo processInfo] processorCount] * 2;
    for (NSUInteger i = 0; i < iterations; i++) {
        [operationQueue addOperationWithBlock:^{
          [self.dHash hashImageData:imageData];
        }];
    }
    [operationQueue waitUntilAllOperationsAreFinished];
    NSDate *t1 = [NSDate date];
    NSTimeInterval executionTime = [t1 timeIntervalSinceDate:t0];
    unsigned long long hashedMBs = filesize * iterations / 1024 / 1024;
    double hashMBsPerS = hashedMBs / executionTime;
    NSLog(@"Hashing %@ MB/s", @(hashMBsPerS));
}

- (void)testPerformanceDHashDistancePerformance
{
    const NSUInteger iterations = 1024 * 128;
    NSData *leftHandImage = [self loadImageAsData:@"blurred/architecture1.bmp"];
    NSData *rightHandImage = [self loadImageAsData:@"blurred/bamarket115.bmp"];
    OSHashType leftHandResult = [self.dHash hashImageData:leftHandImage];
    OSHashType rightHandResult = [self.dHash hashImageData:rightHandImage];
    NSDate *t0 = [NSDate date];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = (NSInteger)[[NSProcessInfo processInfo] processorCount] * 2;
    for (NSUInteger i = 0; i < iterations; i++) {
        [operationQueue addOperationWithBlock:^{
          [self.dHash hashDistance:leftHandResult
                                to:rightHandResult];
        }];
    }
    [operationQueue waitUntilAllOperationsAreFinished];
    NSDate *t1 = [NSDate date];
    NSTimeInterval executionTime = [t1 timeIntervalSinceDate:t0];
    double checksPerS = iterations / executionTime;
    NSLog(@"Calculating %@ checks/s", @(checksPerS));
}

@end
