//
//  OSImageHashing.h
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 10/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import <CocoaImageHashing/OSTypes.h>

/**
 * The OSImageHashing class is the primary way to interact with the CocoaImageHashing framework.
 *
 * It provides APIs for:
 *
 * 1. fingerprint/hash calculation
 * 2. a fingerprint metric
 * 3. concurrent array based similarity search
 * 4. concurrent stream based similarity search
 * 5. sequential array sorting based on fingerprint metrics
 */
@interface OSImageHashing : NSObject <OSImageHashingProvider>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Factory method for instantiating OSImageHashing objects.
 * @return an initialized (shared) OSImageHashing object.
 */
+ (instancetype)sharedInstance;

#pragma mark - OSImageHashingProvider parametrizations

/**
 * @see -[OSImageHashingProvider hashDistance:to:]
 */
- (OSHashDistanceType)hashDistance:(OSHashType)leftHand
                                to:(OSHashType)rightHand
                    withProviderId:(OSImageHashingProviderId)providerId;

/**
 * @see -[OSImageHashingProvider hashImage:]
 */
- (OSHashType)hashImage:(OSImageType *)imageData
         withProviderId:(OSImageHashingProviderId)providerId;

/**
 * @see -[OSImageHashingProvider hashImageData:]
 */
- (OSHashType)hashImageData:(NSData *)imageData
             withProviderId:(OSImageHashingProviderId)providerId;

/**
 * @see -[OSImageHashingProvider hashDistanceSimilarityThreshold]
 */
- (OSHashDistanceType)hashDistanceSimilarityThresholdWithProvider:(OSImageHashingProviderId)providerId;

/**
 * @see -[OSImageHashingProvider compareImageData:to:]
 */
- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
             withQuality:(OSImageHashingQuality)imageHashingQuality;

/**
 * @see -[OSImageHashingProvider compareImageData:to:]
 */
- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
          withProviderId:(OSImageHashingProviderId)providerId;

/**
 * @see -[OSImageHashingProvider compareImageData:to:withDistanceThreshold:]
 */
- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
   withDistanceThreshold:(OSHashDistanceType)distanceThreshold
          withProviderId:(OSImageHashingProviderId)providerId;

/**
 * @see -[OSImageHashingProvider imageSimilarityComparatorForImageForBaseImageData:forLeftHandImageData:forRightHandImageData:]
 */
- (NSComparisonResult)imageSimilarityComparatorForImageForBaseImageData:(NSData *)baseImageData
                                                   forLeftHandImageData:(NSData *)leftHandImageData
                                                  forRightHandImageData:(NSData *)rightHandImageData
                                                         withProviderId:(OSImageHashingProviderId)providerId;

#pragma mark - Concurrent, stream based similarity search

/**
 * Given a stream of images, create an NSArray of tuples containing similar images.
 * 
 * Data is provided through the imageStreamHandler parameter. Returning nil inside imageStreamHandler
 * signals that the stream was closed and no more data is available.
 * 
 * This method nils out all data-tuples it receives allowing for swift garbage collection. If there are no further
 * references to the provided data-tuples, this method will execute in (almost) constant space wrt to image-data.
 *
 * A typical use-case for this method call is to stream uniquely identifiable image-data from a storage system 
 * (e.g. hard-drive, network), then look for similarities and in a second step report that information back to the user.
 * Such an ID can for example be the unique file-path of an image on disk or a database-id referencing an image.
 */
- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                                            forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)(void))imageStreamHandler;

/**
 * @see -[OSImageHashing similarImagesWithHashingQuality::]
 */
- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                                        withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                            forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)(void))imageStreamHandler;

/**
 * @see -[OSImageHashing similarImagesWithHashingQuality::]
 */
- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                      forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)(void))imageStreamHandler;

/**
 * @see -[OSImageHashing similarImagesWithHashingQuality::]
 */
- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                  withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                      forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)(void))imageStreamHandler;

#pragma mark - Concurrent, array based similarity search

/**
 * Given an NSArray of images, create an NSArray of tuples containing similar images.
 *
 * This method requires all image-data to be present in-memory making it impractical for batch operations or
 * handling large data-sets.
 *
 * A typical use-case for this call is to find similar images for a data-set that is already present in memory or 
 * small enough to disregard the memory consumption.
 */
- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                                                        forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)images;

/**
 * @see -[OSImageHashing similarImagesWithHashingQuality::];
 */
- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                                        withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                                        forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)images;

/**
 * @see -[OSImageHashing similarImagesWithHashingQuality::];
 */
- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                                  forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)images;

/**
 * @see -[OSImageHashing similarImagesWithHashingQuality::];
 */
- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                  withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                                  forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)images;

#pragma mark - Array sorting with image similarity metrics for generic NSArrays

/**
 * Sort a generic NSArray with a sort-order defined by the array's content-images distance to a base image.
 */
- (NSArray<id> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                forArray:(NSArray<id> *)array
                                       forImageConverter:(NSData * (^)(id arrayElement))imageConverter;
/*
 * @see -[OSImageHashing sortedArrayUsingImageSimilartyComparator:::];
 */
- (NSArray<id> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                forArray:(NSArray<id> *)array
                               forImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId
                                       forImageConverter:(NSData * (^)(id arrayElement))imageConverter;

/*
 * @see -[OSImageHashing sortedArrayUsingImageSimilartyComparator:::];
 */
- (NSArray<id> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                forArray:(NSArray<id> *)array
                                  forImageHashingQuality:(OSImageHashingQuality)imageHashingQuality
                                       forImageConverter:(NSData * (^)(id arrayElement))imageConverter;

#pragma mark - Array sorting with image similarity metrics for NSData NSArrays

/**
 * Sort an NSArray containing image-data with a sort-order defined by the array's content-images distance to a base image.
 */
- (NSArray<NSData *> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                       forArray:(NSArray<NSData *> *)array;

/**
 * @see -[OSImageHashing sortedArrayUsingImageSimilartyComparator::];
 */
- (NSArray<NSData *> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                       forArray:(NSArray<NSData *> *)array
                                      forImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId;

/**
 * @see -[OSImageHashing sortedArrayUsingImageSimilartyComparator::];
 */
- (NSArray<NSData *> *)sortedArrayUsingImageSimilartyComparator:(NSData *)baseImage
                                                       forArray:(NSArray<NSData *> *)array
                                         forImageHashingQuality:(OSImageHashingQuality)imageHashingQuality;

#pragma mark - Result Conversion

/**
 * @brief A utility conversion method to transform the result of similarImages* methods into an NSDictionary.
 */
- (NSDictionary<OSImageId *, NSSet<OSImageId *> *> *)dictionaryFromSimilarImagesResult:(NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImageTuples;

NS_ASSUME_NONNULL_END

@end
