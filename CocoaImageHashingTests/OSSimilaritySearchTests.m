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

@end
