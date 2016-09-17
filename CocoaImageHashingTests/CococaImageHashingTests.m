//
//  OSImageHashingTests.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 11/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSImageHashingBaseTest.h"

@interface OSImageHashingTests : OSImageHashingBaseTest

@end

@implementation OSImageHashingTests

- (void)testImageSimilarityPublicInterface
{
    NSArray<NSArray<OSDataHolder *> *> *dataSet = [self similarImages];
    [self assertImageSimilarityForProvider:OSImageHashingProviderAHash
                                forDataSet:dataSet];
    [self assertImageSimilarityForProvider:OSImageHashingProviderDHash
                                forDataSet:dataSet];
    [self assertImageSimilarityForProvider:OSImageHashingProviderPHash
                                forDataSet:dataSet];
}

- (void)testImageDiversityOnPublicInterface
{
    NSArray<OSTuple<OSDataHolder *, OSDataHolder *> *> *dataSet = [self diverseImages];
    NSLog(@"Testing %@ combinations", @([dataSet count]));
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = (NSInteger)[[NSProcessInfo processInfo] processorCount] * 2;
    for (OSTuple<OSDataHolder *, OSDataHolder *> *pair in dataSet) {
        [operationQueue addOperationWithBlock:^{
          BOOL result = [[OSImageHashing sharedInstance] compareImageData:OS_CAST_NONNULL(pair.first.data)
                                                                       to:OS_CAST_NONNULL(pair.second.data)
                                                              withQuality:OSImageHashingQualityHigh];

          XCTAssertFalse(result, @"Images should not match: %@ - %@", pair.first.name, pair.second.name);
        }];
    }
    [operationQueue waitUntilAllOperationsAreFinished];
}

@end
