//
//  OSSimilaritySearchTests.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 17/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSImageHashingBaseTest.h"

@interface OSSimilaritySearchTests : OSImageHashingBaseTest

@end

@implementation OSSimilaritySearchTests

- (void)testMemoryLeak
{
    NSMutableArray<OSTuple<OSImageId *, NSData *> *> *dataset = [NSMutableArray new];
    NSData *image = [self loadImageAsData:@"blurred/Tower-Bridge-at-night--London--England_web.bmp"];
    for (NSUInteger i = 0; i < 5000; i++) {
        NSString *identifier = [NSString stringWithFormat:@"%ld", (unsigned long)i];
        OSTuple<OSImageId *, NSData *> *tuple = [OSTuple tupleWithFirst:identifier
                                                              andSecond:image];
        [dataset addObject:tuple];
    }
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [[OSImageHashing sharedInstance]
        similarImagesWithProvider:OSImageHashingProviderDHash
                        forImages:dataset];
    NSUInteger expected = 12497500;
    XCTAssertEqual([result count], expected, @"Invalid match count");
}

- (void)testDictionaryFromSimilarImagesResult
{
    NSArray<NSArray<OSDataHolder *> *> *dataSet = [self similarImages];
    NSUInteger representativesCount = [dataSet count];
    NSUInteger binSize = [[dataSet firstObject] count] - 1;
    NSMutableArray<OSTuple<OSImageId *, OSImageId *> *> *similarTuples = [dataSet valueForKeyPath:@"@unionOfArrays.name.@arrayWithPairCombinations"];
    NSDictionary<OSImageId *, NSSet<OSImageId *> *> *result = [[OSImageHashing sharedInstance] dictionaryFromSimilarImagesResult:similarTuples];
    XCTAssertEqual([result count], representativesCount, @"There should be %lu different representatives", (unsigned long)representativesCount);
    XCTAssertEqualObjects([[result allValues] valueForKeyPath:@"@min.@count"], @(binSize), @"Representatives should not have less than %lu similar images", (unsigned long)binSize);
    XCTAssertEqualObjects([[result allValues] valueForKeyPath:@"@max.@count"], @(binSize), @"Representatives should not have more than %lu similar images", (unsigned long)binSize);
}

@end
