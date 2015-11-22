//
//  OSAbstractHash.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 16/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSAbstractHash.h"
#import "OSImageHashing.h"
#import "OSCategories.h"

@implementation OSAbstractHash

#pragma mark - OSImageHashing Protocol

- (OSHashType)hashImage:(OSImageType *)image
{
    NSAssert(image, @"Image must not be null");
    NSData *data = [image dataRepresentation];
    OSHashType result = [self hashImageData:data];
    return result;
}

- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
{
    NSAssert(leftHandImageData, @"Left hand image data must not be null");
    NSAssert(rightHandImageData, @"Right hand image data must not be null");
    BOOL result = [self compareImageData:leftHandImageData
                                      to:rightHandImageData
                   withDistanceThreshold:[self hashDistanceSimilarityThreshold]];
    return result;
}

- (OSHashDistanceType)hashDistance:(OSHashType)leftHand
                                to:(OSHashType)rightHand
{
    OSHashDistanceType result = (OSHashDistanceType)__builtin_popcountll(leftHand ^ rightHand);
    return result;
}

- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
   withDistanceThreshold:(OSHashDistanceType)distanceThreshold
{
    NSAssert(leftHandImageData, @"Left hand image data must not be null");
    NSAssert(rightHandImageData, @"Right hand image data must not be null");
    OSHashType leftHandImageDataHash = [self hashImageData:leftHandImageData];
    OSHashType rightHandImageDataHash = [self hashImageData:rightHandImageData];
    OSHashDistanceType distance = [self hashDistance:leftHandImageDataHash
                                                  to:rightHandImageDataHash];
    return distance < distanceThreshold;
}

- (NSComparisonResult)imageSimilarityComparatorForImageForBaseImageData:(NSData *)baseImageData
                                                   forLeftHandImageData:(NSData *)leftHandImageData
                                                  forRightHandImageData:(NSData *)rightHandImageData
{
    NSAssert(baseImageData, @"Base image data must not be null");
    NSAssert(rightHandImageData, @"Right hand image data must not be null");
    NSAssert(leftHandImageData, @"Left hand image data must not be null");
    NSAssert(rightHandImageData, @"Right hand image data must not be null");
    OSHashType leftHandImageHash = [self hashImageData:leftHandImageData];
    OSHashType rightHandImageHash = [self hashImageData:rightHandImageData];
    OSHashType baseImageHash = [self hashImageData:baseImageData];
    OSHashDistanceType distanceToLeftImageData = [self hashDistance:leftHandImageHash
                                                                 to:baseImageHash];
    OSHashDistanceType distanceToRightImageData = [self hashDistance:rightHandImageHash
                                                                  to:baseImageHash];
    if (distanceToLeftImageData < distanceToRightImageData) {
        return NSOrderedAscending;
    } else if (distanceToLeftImageData > distanceToRightImageData) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

#pragma mark - Abstract methods

- (OSHashDistanceType)hashDistanceSimilarityThreshold
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Abstract method called."
                                 userInfo:nil];
}

- (OSHashType)hashImageData:(NSData *)imageData
{
    OS_MARK_UNUSED(imageData);
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Abstract method called."
                                 userInfo:nil];
}

@end
