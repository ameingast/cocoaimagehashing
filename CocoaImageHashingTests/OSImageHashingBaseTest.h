//
//  OSImageHashingBaseTest.h
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 12/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

@import XCTest;

#import <CocoaImageHashing/CocoaImageHashing.h>
#import "OSTypes+Internal.h"

@interface OSDataHolder : NSObject

@property (nonatomic) NSData *data;
@property (nonatomic) NSString *name;

+ (OSDataHolder *)holderWithData:(NSData *)data
                         andName:(NSString *)name;

@end

@interface OSImageHashingBaseTest : XCTestCase

@property (strong, nonatomic) NSBundle *bundle;
@property (strong, nonatomic) OSAHash *aHash;
@property (strong, nonatomic) OSDHash *dHash;
@property (strong, nonatomic) OSPHash *pHash;

- (NSData *)loadImageAsData:(NSString *)name;
- (NSArray<NSArray<OSDataHolder *> *> *)similarImages;
- (NSArray<OSTuple<OSDataHolder *, OSDataHolder *> *> *)diverseImages;

- (void)assertHashDistanceEqual:(NSString *)leftHandImageName
             rightHandImageName:(NSString *)rightHandImageName
     withImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId;
- (void)assertHashImagesSimilar:(NSString *)leftHandImageName
             rightHandImageName:(NSString *)rightHandImageName
     withImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId;
- (void)assertHashImagesNotSimilar:(NSString *)leftHandImageName
                rightHandImageName:(NSString *)rightHandImageName
        withImageHashingProviderId:(OSImageHashingProviderId)imageHashingProviderId;
- (void)assertImageSimilarityForProvider:(OSImageHashingProviderId)imageHashingProvider
                              forDataSet:(NSArray<NSArray<OSDataHolder *> *> *)dataSet;

@end
