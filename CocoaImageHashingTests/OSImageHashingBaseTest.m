//
//  OSImageHashingBaseTest.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 12/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSImageHashingBaseTest.h"

@implementation OSDataHolder

@synthesize data = _data;
@synthesize name = _name;

+ (OSDataHolder *)holderWithData:(NSData *)data
                         andName:(NSString *)name
{
    OSDataHolder *holder = [OSDataHolder new];
    holder.data = data;
    holder.name = name;
    return holder;
}

@end

@implementation OSImageHashingBaseTest

@synthesize bundle = _bundle;
@synthesize aHash = _aHash;
@synthesize dHash = _dHash;
@synthesize pHash = _pHash;

#pragma mark - XCTest

- (void)setUp
{
    [super setUp];
    self.bundle = [NSBundle bundleForClass:[self class]];
    self.dHash = [OSDHash sharedInstance];
    self.aHash = [OSAHash sharedInstance];
    self.pHash = [OSPHash sharedInstance];
}

#pragma mark - Fixture Generators

- (NSArray<NSString *> *)imageNames
{
    NSArray<NSString *> *imageNames = @[
        @"Chang_PermanentMidnightintheChairofJasperJohns_large",
        @"Hhirst_BGE",
        @"Scotland_castle_wedding",
        @"Tower-Bridge-at-night--London--England_web",
        @"architecture1",
        @"architecture_2",
        @"bamarket115",
        @"butterflywallpaper",
        @"damien_hirst",
        @"damien_hirst_does_fashion_week",
        @"damien_hirst_virgin_mother",
        @"damienhirst",
        @"dhirst_a3b9ddea",
        @"diamondskull",
        @"doodle",
        @"england",
        @"englandpath",
        @"jasper_johns",
        @"johns_portrait_380x311",
        @"latrobe",
        @"targetjasperjohns",
        @"uk-golf-scotland",
        @"wallacestevens"
    ];

    return imageNames;
}

- (NSArray<NSArray<OSDataHolder *> *> *)similarImages
{
    NSMutableArray<NSArray<OSDataHolder *> *> *result = [NSMutableArray new];
    NSArray<NSString *> *names = [self imageNames];
    for (NSString *imageName in names) {
        NSString *blurredName = [NSString stringWithFormat:@"blurred/%@.bmp", imageName];
        NSString *compressedName = [NSString stringWithFormat:@"compressed/%@.jpg", imageName];
        NSString *miscName = [NSString stringWithFormat:@"misc/%@.bmp", imageName];
        NSData *blurredData = [self loadImageAsData:blurredName];
        NSData *compressedData = [self loadImageAsData:compressedName];
        NSData *miscData = [self loadImageAsData:miscName];
        if (blurredData && compressedData && miscData) {
            [result addObject:@[
                [OSDataHolder holderWithData:blurredData
                                     andName:blurredName],
                [OSDataHolder holderWithData:compressedData
                                     andName:compressedName],
                [OSDataHolder holderWithData:miscData
                                     andName:miscName]
            ]];
        }
    }
    return result;
}

- (NSArray<OSTuple<OSDataHolder *, OSDataHolder *> *> *)diverseImages
{
    NSMutableArray<OSTuple<OSDataHolder *, OSDataHolder *> *> *result = [NSMutableArray new];
    for (NSString *leftHandImageName in [self imageNames]) {
        for (NSString *folderPrefixName in @[@"blurred", @"misc", @"compressed"]) {

            NSString *fileExtension;
            if ([folderPrefixName isEqualToString:@"compressed"]) {
                fileExtension = @"jpg";
            } else {
                fileExtension = @"bmp";
            }
            NSString *blurredLeftHandImageName = [NSString stringWithFormat:@"%@/%@.%@", folderPrefixName, leftHandImageName, fileExtension];
            NSData *blurredLeftHandImageData = [self loadImageAsData:blurredLeftHandImageName];
            for (NSString *rightHandImageName in [self imageNames]) {
                if ([leftHandImageName isEqualToString:rightHandImageName]) {
                    continue;
                }
                NSString *blurredRightHandImageName = [NSString stringWithFormat:@"blurred/%@.bmp", rightHandImageName];
                NSData *blurredRightHandImageData = [self loadImageAsData:blurredRightHandImageName];
                NSString *miscRightHandImageName = [NSString stringWithFormat:@"misc/%@.bmp", rightHandImageName];
                NSData *miscRightHandImageData = [self loadImageAsData:miscRightHandImageName];
                NSString *compressedRightHandImageName = [NSString stringWithFormat:@"compressed/%@.jpg", rightHandImageName];
                NSData *compressedRightHandImageData = [self loadImageAsData:compressedRightHandImageName];
                OSTuple *blurredPair = [OSTuple tupleWithFirst:[OSDataHolder holderWithData:blurredLeftHandImageData
                                                                                    andName:blurredLeftHandImageName]
                                                     andSecond:[OSDataHolder holderWithData:blurredRightHandImageData
                                                                                    andName:blurredRightHandImageName]];
                OSTuple *miscPair = [OSTuple tupleWithFirst:[OSDataHolder holderWithData:blurredLeftHandImageData
                                                                                 andName:blurredLeftHandImageName]
                                                  andSecond:[OSDataHolder holderWithData:miscRightHandImageData
                                                                                 andName:miscRightHandImageName]];
                OSTuple *compressedPair = [OSTuple tupleWithFirst:[OSDataHolder holderWithData:blurredLeftHandImageData
                                                                                       andName:blurredLeftHandImageName]
                                                        andSecond:[OSDataHolder holderWithData:compressedRightHandImageData
                                                                                       andName:compressedRightHandImageName]];
                [result addObject:miscPair];
                [result addObject:blurredPair];
                [result addObject:compressedPair];
            }
        }
    }
    return result;
}

#pragma mark - Utilities

#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR)

- (UIImage *)loadImage:(NSString *)name
{
    NSString *path = [self.bundle pathForResource:[name stringByDeletingPathExtension]
                                           ofType:[name pathExtension]];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    return image;
}

#else

- (NSImage *)loadImage:(NSString *)name
{
    NSString *path = [self.bundle pathForResource:[name stringByDeletingPathExtension]
                                           ofType:[name pathExtension]];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
    return image;
}

#endif

- (NSData *)loadImageAsData:(NSString *)name
{
    static NSMutableDictionary<NSString *, NSData *> *imageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      imageCache = [NSMutableDictionary new];
    });
    @synchronized(imageCache)
    {
        NSData *cachedData = imageCache[name];
        if (cachedData) {
            return cachedData;
        }
    }
    OSImageType *image = [self loadImage:name];
    NSData *result = [image dataRepresentation];
    @synchronized(imageCache)
    {
        imageCache[name] = result;
    }
    return result;
}

#pragma mark - Hash Asserts

- (void)assertHashDistanceEqual:(NSString *)leftHandImageName
             rightHandImageName:(NSString *)rightHandImageName
     withImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId
{
    NSData *leftHandImage = [self loadImageAsData:leftHandImageName];
    NSData *rightHandImage = [self loadImageAsData:rightHandImageName];
    OSHashType leftHandResult = [[OSImageHashing sharedInstance] hashImageData:leftHandImage
                                                                withProviderId:imageHashingProviderId];
    OSHashType rightHandResult = [[OSImageHashing sharedInstance] hashImageData:rightHandImage
                                                                 withProviderId:imageHashingProviderId];
    OSHashDistanceType distance = [[OSImageHashing sharedInstance] hashDistance:leftHandResult
                                                                             to:rightHandResult
                                                                 withProviderId:imageHashingProviderId];
    XCTAssertEqual((NSInteger)0, distance, @"Images should have 0 distance: %@ - %@", leftHandImageName, rightHandImageName);
}

- (void)assertHashImagesSimilar:(NSString *)leftHandImageName
             rightHandImageName:(NSString *)rightHandImageName
     withImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId
{
    NSData *leftHandImage = [self loadImageAsData:leftHandImageName];
    NSData *rightHandImage = [self loadImageAsData:rightHandImageName];
    OSHashType leftHandResult = [[OSImageHashing sharedInstance] hashImageData:leftHandImage
                                                                withProviderId:imageHashingProviderId];
    OSHashType rightHandResult = [[OSImageHashing sharedInstance] hashImageData:rightHandImage
                                                                 withProviderId:imageHashingProviderId];
    OSHashDistanceType distance = [[OSImageHashing sharedInstance] hashDistance:leftHandResult
                                                                             to:rightHandResult
                                                                 withProviderId:imageHashingProviderId];
    OSHashDistanceType distanceThreshold = [[OSImageHashing sharedInstance] hashDistanceSimilarityThresholdWithProvider:imageHashingProviderId];
    XCTAssertLessThan(distance, distanceThreshold, @"Images should match: %@ - %@", leftHandImageName, rightHandImageName);
}

- (void)assertHashImagesNotSimilar:(NSString *)leftHandImageName
                rightHandImageName:(NSString *)rightHandImageName
        withImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId
{
    NSData *leftHandImage = [self loadImageAsData:leftHandImageName];
    NSData *rightHandImage = [self loadImageAsData:rightHandImageName];
    OSHashType leftHandResult = [[OSImageHashing sharedInstance] hashImageData:leftHandImage
                                                                withProviderId:imageHashingProviderId];
    OSHashType rightHandResult = [[OSImageHashing sharedInstance] hashImageData:rightHandImage
                                                                 withProviderId:imageHashingProviderId];
    OSHashDistanceType distance = [[OSImageHashing sharedInstance] hashDistance:leftHandResult
                                                                             to:rightHandResult
                                                                 withProviderId:imageHashingProviderId];
    OSHashDistanceType distanceThreshold = [[OSImageHashing sharedInstance] hashDistanceSimilarityThresholdWithProvider:imageHashingProviderId];
    XCTAssertGreaterThanOrEqual(distance, distanceThreshold, @"Images should not match: %@ - %@", leftHandImageName, rightHandImageName);
}

- (void)assertImageSimilarityForProvider:(OSImageHashingProviderId)imageHashingProvider
                              forDataSet:(NSArray<NSArray<OSDataHolder *> *> *)dataSet
{
    for (NSArray<OSDataHolder *> *subSet in dataSet) {
        NSUInteger __block i = 0;
        NSArray<OSTuple<NSString *, NSString *> *> *resultSet = [[OSImageHashing sharedInstance]
            similarImagesWithProvider:imageHashingProvider
                forImageStreamHandler:^OSTuple<NSString *, NSData *> * {
                  if (i >= [subSet count]) {
                      return nil;
                  }
                  OSTuple<NSString *, NSData *> *tuple = [OSTuple tupleWithFirst:subSet[i].name
                                                                       andSecond:subSet[i].data];
                  i++;
                  return tuple;
                }];
        XCTAssertEqual([resultSet count], [subSet count], @"Not all images are matching");
    }
}

// Hashes should never change for same images. Users of this library are relying on the values.
- (void)assertHashOfImageWithName:(NSString *)imageName
                        isEqualTo:(OSHashType)referenceHash
                      forProvider:(OSImageHashingProviderId)imageHashingProvider
{
    NSData *imageData = [self loadImageAsData:imageName];
    OSHashType actualHash = [[OSImageHashing sharedInstance] hashImageData:imageData
                                                            withProviderId:imageHashingProvider];
    
    XCTAssertEqual(actualHash, referenceHash, @"Actual hash do not match reference hash");
}

@end
