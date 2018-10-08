//
//  OSAHashTests.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 11/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSImageHashingBaseTest.h"

@interface OSAHashTests : OSImageHashingBaseTest

@end

@implementation OSAHashTests

- (void)testAHashOnEqualImages
{
    [self assertHashDistanceEqual:@"blurred/architecture1.bmp"
                rightHandImageName:@"blurred/architecture1.bmp"
        withImageHashingProviderId:OSImageHashingProviderAHash];
}

- (void)testAHashOnSimilarImages
{
    [self assertHashImagesSimilar:@"blurred/architecture1.bmp"
                rightHandImageName:@"compressed/architecture1.jpg"
        withImageHashingProviderId:OSImageHashingProviderAHash];
}

- (void)testDataHashingWithMalformedInput
{
    NSData *data = [NSMutableData dataWithLength:1024 * 1024];
    OSHashType result = [self.aHash hashImageData:data];
    XCTAssertEqual(OSHashTypeError, result);
}

- (void)testAHashValuesRegression
{
    [self assertHashOfImageWithName:@"blurred/architecture1.bmp"
                          isEqualTo:-8608191228601917537
                        forProvider:OSImageHashingProviderAHash];
    [self assertHashOfImageWithName:@"compressed/architecture1.jpg"
                          isEqualTo:-8608472703578630209
                        forProvider:OSImageHashingProviderAHash];
    [self assertHashOfImageWithName:@"blurred/bamarket115.bmp"
                          isEqualTo:-16954737706286081
                        forProvider:OSImageHashingProviderAHash];
}

@end
