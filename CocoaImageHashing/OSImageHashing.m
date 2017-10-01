//
//  OSImageHashing.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 10/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSImageHashing.h"
#import "OSCategories.h"
#import "OSSimilaritySearch.h"

@implementation OSImageHashing

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [self new];
    });
    return instance;
}

#pragma mark - OSImageHashingProvider

- (OSHashDistanceType)hashDistance:(OSHashType)leftHand
                                to:(OSHashType)rightHand
{
    OSImageHashingProviderId providerId = OSImageHashingProviderDefaultProviderId();
    OSHashDistanceType result = [self hashDistance:leftHand
                                                to:rightHand
                                    withProviderId:providerId];
    return result;
}

- (OSHashType)hashImage:(OSImageType *)image
{
    OSImageHashingProviderId providerId = OSImageHashingProviderDefaultProviderId();
    OSHashType result = [self hashImage:image
                         withProviderId:providerId];
    return result;
}

- (OSHashType)hashImageData:(NSData *)imageData
{
    OSImageHashingProviderId providerId = OSImageHashingProviderDefaultProviderId();
    OSHashType result = [self hashImageData:imageData
                             withProviderId:providerId];
    return result;
}

- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
{
    OSImageHashingProviderId providerId = OSImageHashingProviderDefaultProviderId();
    BOOL result = [self compareImageData:leftHandImageData
                                      to:rightHandImageData
                          withProviderId:providerId];
    return result;
}

- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
   withDistanceThreshold:(OSHashDistanceType)distanceThreshold
{
    OSImageHashingProviderId providerId = OSImageHashingProviderDefaultProviderId();
    BOOL result = [self compareImageData:leftHandImageData
                                      to:rightHandImageData
                   withDistanceThreshold:distanceThreshold
                          withProviderId:providerId];
    return result;
}

- (NSComparisonResult)imageSimilarityComparatorForImageForBaseImageData:(NSData *)baseImageData
                                                   forLeftHandImageData:(NSData *)leftHandImageData
                                                  forRightHandImageData:(NSData *)rightHandImageData
{
    OSImageHashingProviderId providerId = OSImageHashingProviderDefaultProviderId();
    NSComparisonResult result = [self imageSimilarityComparatorForImageForBaseImageData:baseImageData
                                                                   forLeftHandImageData:leftHandImageData
                                                                  forRightHandImageData:rightHandImageData
                                                                         withProviderId:providerId];
    return result;
}

- (OSHashDistanceType)hashDistanceSimilarityThreshold
{
    OSImageHashingProviderId providerId = OSImageHashingProviderDefaultProviderId();
    OSHashDistanceType result = [self hashDistanceSimilarityThresholdWithProvider:providerId];
    return result;
}

#pragma mark - OSImageHashingProvider parametrizations

- (OSHashDistanceType)hashDistance:(OSHashType)leftHand
                                to:(OSHashType)rightHand
                    withProviderId:(OSImageHashingProviderId)providerId
{
    id<OSImageHashingProvider> provider = OSImageHashingProviderFromImageHashingProviderId(providerId);
    OSHashDistanceType result = [provider hashDistance:leftHand
                                                    to:rightHand];
    return result;
}

- (OSHashType)hashImage:(OSImageType *)imageData
         withProviderId:(OSImageHashingProviderId)providerId
{
    id<OSImageHashingProvider> provider = OSImageHashingProviderFromImageHashingProviderId(providerId);
    OSHashType result = [provider hashImage:imageData];
    return result;
}

- (OSHashType)hashImageData:(NSData *)imageData
             withProviderId:(OSImageHashingProviderId)providerId
{
    id<OSImageHashingProvider> provider = OSImageHashingProviderFromImageHashingProviderId(providerId);
    OSHashType result = [provider hashImageData:imageData];
    return result;
}

- (OSHashDistanceType)hashDistanceSimilarityThresholdWithProvider:(OSImageHashingProviderId)providerId
{
    id<OSImageHashingProvider> provider = OSImageHashingProviderFromImageHashingProviderId(providerId);
    OSHashDistanceType result = [provider hashDistanceSimilarityThreshold];
    return result;
}

- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
             withQuality:(OSImageHashingQuality)imageHashingQuality
{
    OSImageHashingProviderId hashingProvider = OSImageHashingProviderIdForHashingQuality(imageHashingQuality);
    BOOL result = [self compareImageData:leftHandImageData
                                      to:rightHandImageData
                          withProviderId:hashingProvider];
    return result;
}

- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
          withProviderId:(OSImageHashingProviderId)providerId
{
    id<OSImageHashingProvider> firstProdiver = OSImageHashingProviderFromImageHashingProviderId(providerId);
    OSHashDistanceType distanceThreshold = [firstProdiver hashDistanceSimilarityThreshold];
    BOOL result = [self compareImageData:leftHandImageData
                                      to:rightHandImageData
                   withDistanceThreshold:distanceThreshold
                          withProviderId:providerId];
    return result;
}

- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
   withDistanceThreshold:(OSHashDistanceType)distanceThreshold
          withProviderId:(OSImageHashingProviderId)providerId
{
    NSArray<id<OSImageHashingProvider>> *hashingProviders = NSArrayForProvidersFromOSImageHashingProviderId(providerId);
    for (id<OSImageHashingProvider> hashingProvider in hashingProviders) {
        BOOL result = [hashingProvider compareImageData:leftHandImageData
                                                     to:rightHandImageData
                                  withDistanceThreshold:distanceThreshold];
        if (!result) {
            return NO;
        }
    }
    return YES;
}

- (NSComparisonResult)imageSimilarityComparatorForImageForBaseImageData:(NSData *)baseImageData
                                                   forLeftHandImageData:(NSData *)leftHandImageData
                                                  forRightHandImageData:(NSData *)rightHandImageData
                                                         withProviderId:(OSImageHashingProviderId)providerId
{
    id<OSImageHashingProvider> provider = OSImageHashingProviderFromImageHashingProviderId(providerId);
    NSComparisonResult result = [provider imageSimilarityComparatorForImageForBaseImageData:baseImageData
                                                                       forLeftHandImageData:leftHandImageData
                                                                      forRightHandImageData:rightHandImageData];
    return result;
}

#pragma mark - Concurrent, stream based similarity search

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                                            forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)(void))imageStreamHandler
{
    OSImageHashingProviderId providerId = OSImageHashingProviderIdForHashingQuality(imageHashingQuality);
    id<OSImageHashingProvider> firstProvider = OSImageHashingProviderFromImageHashingProviderId(providerId);
    OSHashDistanceType hashDistanceTreshold = [firstProvider hashDistanceSimilarityThreshold];
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [self similarImagesWithHashingQuality:imageHashingQuality
                                                                       withHashDistanceThreshold:hashDistanceTreshold
                                                                           forImageStreamHandler:imageStreamHandler];
    return result;
}

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                                        withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                            forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)(void))imageStreamHandler
{
    OSImageHashingProviderId hashingProvider = OSImageHashingProviderIdForHashingQuality(imageHashingQuality);
    NSArray<OSTuple<NSString *, NSString *> *> *result = [self similarImagesWithProvider:hashingProvider
                                                               withHashDistanceThreshold:hashDistanceThreshold
                                                                   forImageStreamHandler:imageStreamHandler];
    return result;
}

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                      forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)(void))imageStreamHandler
{
    id<OSImageHashingProvider> firstProvider = OSImageHashingProviderFromImageHashingProviderId(imageHashingProviderId);
    OSHashDistanceType hashDistanceTreshold = [firstProvider hashDistanceSimilarityThreshold];
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [self similarImagesWithProvider:imageHashingProviderId
                                                                 withHashDistanceThreshold:hashDistanceTreshold
                                                                     forImageStreamHandler:imageStreamHandler];
    return result;
}

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                  withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                      forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)(void))imageStreamHandler
{
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [[OSSimilaritySearch sharedInstance] similarImagesWithProvider:imageHashingProviderId
                                                                                                withHashDistanceThreshold:hashDistanceThreshold
                                                                                                    forImageStreamHandler:imageStreamHandler];
    return result;
}

#pragma mark - Concurrent, array based similarity search

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                                                        forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)images
{
    OSImageHashingProviderId providerId = OSImageHashingProviderIdForHashingQuality(imageHashingQuality);
    id<OSImageHashingProvider> firstProvider = OSImageHashingProviderFromImageHashingProviderId(providerId);
    OSHashDistanceType hashDistanceTreshold = [firstProvider hashDistanceSimilarityThreshold];
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [self similarImagesWithHashingQuality:imageHashingQuality
                                                                       withHashDistanceThreshold:hashDistanceTreshold
                                                                                       forImages:images];
    return result;
}

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                                        withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                                        forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)images
{
    OSImageHashingProviderId providerId = OSImageHashingProviderIdForHashingQuality(imageHashingQuality);
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [self similarImagesWithProvider:providerId
                                                                 withHashDistanceThreshold:hashDistanceThreshold
                                                                                 forImages:images];
    return result;
}

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                                  forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)images
{
    id<OSImageHashingProvider> imageHashingProvider = OSImageHashingProviderFromImageHashingProviderId(imageHashingProviderId);
    OSHashDistanceType hashDistanceTreshold = [imageHashingProvider hashDistanceSimilarityThreshold];
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [self similarImagesWithProvider:imageHashingProviderId
                                                                 withHashDistanceThreshold:hashDistanceTreshold
                                                                                 forImages:images];
    return result;
}

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                  withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                                  forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)images
{
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [[OSSimilaritySearch sharedInstance] similarImagesWithProvider:imageHashingProviderId
                                                                                                withHashDistanceThreshold:hashDistanceThreshold
                                                                                                                forImages:images];
    return result;
}

#pragma mark - Array sorting with image similarity metrics for generic NSArrays

- (NSArray<id> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                 forArray:(NSArray<id> *)array
                                        forImageConverter:(NSData * (^)(id arrayElement))imageConverter
{
    OSImageHashingProviderId imageHashingProviderId = OSImageHashingProviderDefaultProviderId();
    return [self sortedArrayUsingImageSimilartyComparator:baseImage
                                                 forArray:array
                                forImageHashingProviderId:imageHashingProviderId
                                        forImageConverter:imageConverter];
}

- (NSArray<id> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                 forArray:(NSArray<id> *)array
                                forImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId
                                        forImageConverter:(NSData * (^)(id arrayElement))imageConverter
{
    NSAssert(baseImage, @"Base image must not be null");
    NSAssert(array, @"Array must not be null");
    NSAssert(imageConverter, @"Image converter must not be null");
    NSArray<id> *result = [array sortedArrayUsingComparator:^NSComparisonResult(id leftHandElement, id rightHandElement) {
      NSData *leftHandImageData = imageConverter(leftHandElement);
      NSData *rightHandImageData = imageConverter(rightHandElement);
      NSComparisonResult comparisonResult = [[OSImageHashing sharedInstance] imageSimilarityComparatorForImageForBaseImageData:baseImage
                                                                                                          forLeftHandImageData:leftHandImageData
                                                                                                         forRightHandImageData:rightHandImageData
                                                                                                                withProviderId:imageHashingProviderId];
      return comparisonResult;
    }];
    return result;
}

- (NSArray<id> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                 forArray:(NSArray<id> *)array
                                   forImageHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                        forImageConverter:(NSData * (^)(id arrayElement))imageConverter
{
    OSImageHashingProviderId imageHashingProviderId = OSImageHashingProviderIdForHashingQuality(imageHashingQuality);
    return [self sortedArrayUsingImageSimilartyComparator:baseImage
                                                 forArray:array
                                forImageHashingProviderId:imageHashingProviderId
                                        forImageConverter:imageConverter];
}

#pragma mark - Array sorting with image similarity metrics for NSData NSArrays

- (NSArray<NSData *> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                       forArray:(NSArray<NSData *> *)array
{
    NSArray<NSData *> *result = [self sortedArrayUsingImageSimilartyComparator:baseImage
                                                                      forArray:array
                                                             forImageConverter:^NSData *(NSData *arrayElement) {
                                                               return arrayElement;
                                                             }];
    return result;
}

- (NSArray<NSData *> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                       forArray:(NSArray<NSData *> *)array
                                      forImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId
{
    NSArray<NSData *> *result = [self sortedArrayUsingImageSimilartyComparator:baseImage
                                                                      forArray:array
                                                     forImageHashingProviderId:imageHashingProviderId
                                                             forImageConverter:^NSData *(NSData *arrayElement) {
                                                               return arrayElement;
                                                             }];
    return result;
}

- (NSArray<NSData *> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                       forArray:(NSArray<NSData *> *)array
                                         forImageHashingQuality:(OSImageHashingQuality)imageHashingQuality
{
    NSArray<NSData *> *result = [self sortedArrayUsingImageSimilartyComparator:baseImage
                                                                      forArray:array
                                                        forImageHashingQuality:imageHashingQuality
                                                             forImageConverter:^NSData *(NSData *arrayElement) {
                                                               return arrayElement;
                                                             }];
    return result;
}

#pragma mark - Result Conversion

- (NSDictionary<OSImageId *, NSSet<OSImageId *> *> *)dictionaryFromSimilarImagesResult:(NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImageTuples
{
    NSDictionary<OSImageId *, NSSet<OSImageId *> *> *result = [[OSSimilaritySearch sharedInstance] dictionaryFromSimilarImagesResult:similarImageTuples];
    return result;
}

@end
