//
//  OSTypes.h
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 14/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

@import Foundation;

#pragma mark - Cross Platform Type Aliases

#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR)
@class UIImage;
#define OSImageType UIImage
#else
@class NSImage;
#define OSImageType NSImage
#endif

#pragma mark - Primitive Type Definitions

/**
 * OSHashType represents a fingerprint of an image.
 *
 * OSHashTypeError represents an error in the hash calculation.
 */
typedef SInt64 OSHashType;

/**
 * OSHashDistanceType represents the distance between two image fingerprints.
 */
typedef SInt64 OSHashDistanceType;

/**
 * A type alias to help identify images by an id.
 */
typedef NSString OSImageId;

/**
 * OSImageHashingProviderId is a combinable id-type to identify OSImageHashing providers.
 * This type is used in the OSImageHashing API to configure a specific OSImageHashing provider.
 *
 * If two or more providers are combined, their order is defined as follows:
 *      OSImageHashingProviderDHash < OSImageHashingProviderPHash < OSImageHashingProviderAHash
 */
typedef NS_OPTIONS(UInt16, OSImageHashingProviderId) {
    OSImageHashingProviderAHash = 1 << 0,
    OSImageHashingProviderDHash = 1 << 1,
    OSImageHashingProviderPHash = 1 << 2,
    OSImageHashingProviderNone = 0
};

/**
 * OSImageHashingQuality represents the quality used to calculate image hashes. The higher the quality, the more CPU
 * time and memory is consumed for calculating the image fingerprints. 
 *
 * Selecting a higher priority typically improves hashing quality and reduces number of false-positives significantly
 * (by chaining different hashing providers to refine and check the calculated result).
 */
typedef NS_ENUM(UInt16, OSImageHashingQuality) {
    OSImageHashingQualityLow,
    OSImageHashingQualityMedium,
    OSImageHashingQualityHigh,
    OSImageHashingQualityNone
};

#pragma mark - Error Values

/**
 * OSHashTypeError represents an OSHashType error result.
 */
extern const OSHashType OSHashTypeError;

#pragma mark - Image Hashing Protocol

/**
 * Create perceptual fingerprints for image data.
 * 
 * OSImageHashingProviders have to offer the following functionality
 *
 * 1. Creating a 64-bit fingerprint for a given image
 * 2. Calculating the distance between two fingerprints
 * 3. Having a default similarity threshold that can be used if two images are similar
 * 4. Determining if two images are similar
 */
@protocol OSImageHashingProvider

NS_ASSUME_NONNULL_BEGIN

/**
 * Returns a shared instance for the hashing provider.
 */
+ (instancetype)sharedInstance;

/**
 * Calculate the fingerprint/hash for a given image.
 *
 * The result is a 64-bit number. Returns OSHashTypeError if an error occurs during image processing.
 */
- (OSHashType)hashImage:(OSImageType *)image;

/**
 * @see -[OSImageHashing hashImage:]
 */
- (OSHashType)hashImageData:(NSData *)imageData;

/**
 * Calculate the hash distance between two fingerprints/hashes.
 *
 * The hash distance is defined as the bit-to-bit difference between `leftHand` and `rightHand`.
 *
 * The `leftHand` and `rightHand` parameters must not be OSHashTypeError. 
 */
- (OSHashDistanceType)hashDistance:(OSHashType)leftHand
                                to:(OSHashType)rightHand;

/**
 * Determines the threshold when two image fingerprints are to be considered similar.
 *
 * This value depends on the algorithm in the concrete OSImageHashingProvider implementation.
 */
- (OSHashDistanceType)hashDistanceSimilarityThreshold;

/**
 * Determines if two images (in this case, their data representation) are similar.
 *
 * Two images are said to be similar if the following statement holds: 
 * 
 *      distance(Fingerprint(image1), Fingerprint(image2)) < DistanceThreshold
 */
- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData;

/**
 * @see -[OSImageHashing compareImageData::]
 */
- (BOOL)compareImageData:(NSData *)leftHandImageData
                      to:(NSData *)rightHandImageData
   withDistanceThreshold:(OSHashDistanceType)distanceThreshold;

/**
 * This method is used to create an NSComparisonResult which can be used to sort an image collection wrt their similarity to a image.
 */
- (NSComparisonResult)imageSimilarityComparatorForImageForBaseImageData:(NSData *)baseImageData
                                                   forLeftHandImageData:(NSData *)leftHandImageData
                                                  forRightHandImageData:(NSData *)rightHandImageData;

NS_ASSUME_NONNULL_END

@end

#pragma mark - Tuples

/**
 * A fast, lockless, generic  2-tuple implementation.
 */
@interface OSTuple<A, B> : NSObject

@property (strong, nonatomic, nullable) A first;
@property (strong, nonatomic, nullable) B second;

/**
 * A factory method to instantiate a OSTuple with two given parameters.
 */
+ (nonnull instancetype)tupleWithFirst:(nullable A)first
                             andSecond:(nullable B)second;

/**
 * A factory method to instantiate a OSTuple with two given parameters.
 */
- (nonnull instancetype)initWithFirst:(nullable A)first
                            andSecond:(nullable B)second;

@end

/**
 * A fast, lockless, specific 2-tuple implementation storing a generic first-value and a OSHAshType second-value.
 */
@interface OSHashResultTuple<A> : NSObject

@property (strong, nonatomic, nullable) A first;
@property (nonatomic) OSHashType hashResult;

@end

#pragma mark - Primitive Type Functions and Utilities

NS_ASSUME_NONNULL_BEGIN

OSImageHashingProviderId OSImageHashingProviderDefaultProviderId(void);

OSImageHashingProviderId OSImageHashingProviderIdFromString(NSString *name);
NSString *NSStringFromOSImageHashingProviderId(OSImageHashingProviderId providerId);
NSArray<NSNumber *> *NSArrayFromOSImageHashingProviderId(void);
NSArray<NSString *> *NSArrayFromOSImageHashingProviderIdNames(void);

OSImageHashingQuality OSImageHashingQualityFromString(NSString *name);
NSString *NSStringFromOSImageHashingQuality(OSImageHashingQuality hashingQuality);
NSArray<NSNumber *> *NSArrayFromOSImageHashingQuality(void);
NSArray<NSString *> *NSArrayFromOSImageHashingQualityNames(void);

OSImageHashingProviderId OSImageHashingProviderIdForHashingQuality(OSImageHashingQuality hashingQuality);
id<OSImageHashingProvider> OSImageHashingProviderFromImageHashingProviderId(OSImageHashingProviderId imageHashingProviderId);
NSArray<id<OSImageHashingProvider>> *NSArrayForProvidersFromOSImageHashingProviderId(OSImageHashingProviderId imageHashingProviderId);

NS_ASSUME_NONNULL_END
