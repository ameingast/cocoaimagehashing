//
//  OSTypes.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 15/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSAHash.h"
#import "OSDHash.h"
#import "OSPHash.h"
#import "OSTypes.h"

#pragma mark - Error Values

const OSHashType OSHashTypeError = -1;

#pragma mark - Categories

@implementation OSTuple

@synthesize first = _first;
@synthesize second = _second;

+ (nonnull instancetype)tupleWithFirst:(nullable id)first
                             andSecond:(nullable id)second
{
    id this = [self alloc];
    return [this initWithFirst:first
                     andSecond:second];
}

- (nonnull instancetype)initWithFirst:(nullable id)first
                            andSecond:(nullable id)second
{
    self = [super init];
    if (self) {
        _first = first;
        _second = second;
    }
    return self;
}

- (NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"<%@: %p, first: %@, second: %@>",
                                                  NSStringFromClass([self class]), (__bridge void *)self, _first, _second];
    return result;
}

@end

@implementation OSHashResultTuple

@synthesize first = _first;
@synthesize hashResult = _hashResult;

@end

#pragma mark - Primitive Type Functions and Utilities

inline OSImageHashingProviderId OSImageHashingProviderDefaultProviderId(void)
{
    return OSImageHashingProviderDHash;
}

inline OSImageHashingProviderId OSImageHashingProviderIdFromString(NSString *name)
{
    NSCAssert(name, @"Image hashing provider name must not be null");
    if ([name isEqualToString:@"aHash"]) {
        return OSImageHashingProviderAHash;
    } else if ([name isEqualToString:@"dHash"]) {
        return OSImageHashingProviderDHash;
    } else if ([name isEqualToString:@"pHash"]) {
        return OSImageHashingProviderPHash;
    } else {
        return OSImageHashingProviderNone;
    }
}

inline NSString *NSStringFromOSImageHashingProviderId(OSImageHashingProviderId providerId)
{
    switch (providerId) {
        case OSImageHashingProviderAHash:
            return @"aHash";
        case OSImageHashingProviderDHash:
            return @"dHash";
        case OSImageHashingProviderPHash:
            return @"pHash";
        case OSImageHashingProviderNone:
            return @"None";
    }
    return nil;
}

inline NSArray<NSNumber *> *NSArrayFromOSImageHashingProviderId()
{
    return @[@(OSImageHashingProviderAHash), @(OSImageHashingProviderDHash), @(OSImageHashingProviderPHash)];
}

inline NSArray<NSString *> *NSArrayFromOSImageHashingProviderIdNames()
{
    NSMutableArray<NSString *> *result = [NSMutableArray new];
    for (NSNumber *providerNumber in NSArrayFromOSImageHashingProviderId()) {
        OSImageHashingProviderId category = (OSImageHashingProviderId)[providerNumber integerValue];
        NSString *providerName = NSStringFromOSImageHashingProviderId(category);
        [result addObject:providerName];
    }
    return result;
}

inline OSImageHashingQuality OSImageHashingQualityFromString(NSString *name)
{
    NSCAssert(name, @"Image hashing quality name must not be null");
    if ([name isEqualToString:@"Low"]) {
        return OSImageHashingQualityLow;
    } else if ([name isEqualToString:@"Medium"]) {
        return OSImageHashingQualityMedium;
    } else if ([name isEqualToString:@"High"]) {
        return OSImageHashingQualityHigh;
    } else {
        return OSImageHashingQualityNone;
    }
}

inline NSString *NSStringFromOSImageHashingQuality(OSImageHashingQuality hashingQuality)
{
    switch (hashingQuality) {
        case OSImageHashingQualityLow:
            return @"Low";
        case OSImageHashingQualityMedium:
            return @"Medium";
        case OSImageHashingQualityHigh:
            return @"High";
        case OSImageHashingQualityNone:
            return @"None";
    }
    return nil;
}

inline NSArray<NSNumber *> *NSArrayFromOSImageHashingQuality()
{
    return @[@(OSImageHashingQualityLow), @(OSImageHashingQualityMedium), @(OSImageHashingQualityHigh)];
}

inline NSArray<NSString *> *NSArrayFromOSImageHashingQualityNames()
{
    NSMutableArray<NSString *> *result = [NSMutableArray new];
    for (NSNumber *qualityNumber in NSArrayFromOSImageHashingQuality()) {
        OSImageHashingQuality hashingQuality = (OSImageHashingQuality)[qualityNumber integerValue];
        NSString *hashingQualityName = NSStringFromOSImageHashingQuality(hashingQuality);
        [result addObject:hashingQualityName];
    }
    return result;
}

inline OSImageHashingProviderId OSImageHashingProviderIdForHashingQuality(OSImageHashingQuality hashingQuality)
{
    switch (hashingQuality) {
        case OSImageHashingQualityLow:
        case OSImageHashingQualityMedium:
        case OSImageHashingQualityHigh:
            return OSImageHashingProviderDHash;
        case OSImageHashingQualityNone:
            return OSImageHashingProviderNone;
    }
}

inline id<OSImageHashingProvider> OSImageHashingProviderFromImageHashingProviderId(OSImageHashingProviderId imageHashingProviderId)
{
    NSArray<id<OSImageHashingProvider>> *providers = NSArrayForProvidersFromOSImageHashingProviderId(imageHashingProviderId);
    id<OSImageHashingProvider> provider = [providers firstObject];
    return provider;
}

inline NSArray<id<OSImageHashingProvider>> *NSArrayForProvidersFromOSImageHashingProviderId(OSImageHashingProviderId imageHashingProviderId)
{
    NSMutableArray<id<OSImageHashingProvider>> *providers = [NSMutableArray new];
    if ((imageHashingProviderId & OSImageHashingProviderDHash)) {
        [providers addObject:[OSDHash sharedInstance]];
    }
    if ((imageHashingProviderId & OSImageHashingProviderPHash)) {
        [providers addObject:[OSPHash sharedInstance]];
    }
    if ((imageHashingProviderId & OSImageHashingProviderAHash)) {
        [providers addObject:[OSAHash sharedInstance]];
    }
    return providers;
}
