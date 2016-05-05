//
//  OSSimilaritySearch.m
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 16/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSSimilaritySearch.h"
#import "OSCategories.h"
#import "OSImageHashing.h"

@implementation OSSimilaritySearch

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [self new];
    });
    return instance;
}

#pragma mark - Collection & Stream Based Similarity Search

- (void)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
        withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
            forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)())imageStreamHandler
                 forResultHandler:(void (^)(OSImageId *leftHandImageId, OSImageId *rightHandImageId))resultHandler
{
    NSAssert(imageStreamHandler, @"Image stream handler must not be nil");
    NSAssert(resultHandler, @"Result handler must not be nil");
    NSMutableArray<OSHashResultTuple<NSString *> *> __block *fingerPrintedTuples = [NSMutableArray new];
    NSUInteger cpuCount = [[NSProcessInfo processInfo] processorCount];
    dispatch_semaphore_t hashingSemaphore = dispatch_semaphore_create((long)cpuCount);
    dispatch_group_t hashingDispatchGroup = dispatch_group_create();
    for (;;) {
        OSTuple<NSString *, NSData *> __block *inputTuple = imageStreamHandler();
        if (!inputTuple) {
            break;
        }
        dispatch_semaphore_wait(hashingSemaphore, DISPATCH_TIME_FOREVER);
        dispatch_group_async(hashingDispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          NSString *identifier = inputTuple.first;
          NSData *imageData = inputTuple.second;
          OSHashType hashResult = [[OSImageHashing sharedInstance] hashImageData:imageData
                                                                  withProviderId:imageHashingProviderId];
          inputTuple.first = nil;
          inputTuple.second = nil;
          inputTuple = nil;
          OSHashResultTuple<NSString *> *resultTuple = [OSHashResultTuple new];
          resultTuple.first = identifier;
          resultTuple.hashResult = hashResult;
          @synchronized(fingerPrintedTuples)
          {
              [fingerPrintedTuples addObject:resultTuple];
          }
          dispatch_semaphore_signal(hashingSemaphore);
        });
    }
    dispatch_group_wait(hashingDispatchGroup, DISPATCH_TIME_FOREVER);
    [fingerPrintedTuples arrayWithPairCombinations:^BOOL(OSHashResultTuple *leftHandTuple, OSHashResultTuple *rightHandTuple) {
      OSHashDistanceType hashDistance = [[OSImageHashing sharedInstance] hashDistance:leftHandTuple.hashResult
                                                                                   to:rightHandTuple.hashResult
                                                                       withProviderId:imageHashingProviderId];
      BOOL result = hashDistance <= hashDistanceThreshold;
      return result;
    } withResultHandler:^(OSHashResultTuple *leftHandTuple, OSHashResultTuple *rightHandTuple) {
      OSImageId *leftHandImageId = leftHandTuple.first;
      OSImageId *rightHandImageId = rightHandTuple.first;
      resultHandler(leftHandImageId, rightHandImageId);
    }];
}

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                  withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                      forImageStreamHandler:(OSTuple<OSImageId *, NSData *> * (^)())imageStreamHandler
{
    NSAssert(imageStreamHandler, @"Image stream handler must not be nil");
    NSMutableArray<OSTuple<NSString *, NSString *> *> *tuples = [NSMutableArray new];
    [self similarImagesWithProvider:imageHashingProviderId
          withHashDistanceThreshold:hashDistanceThreshold
              forImageStreamHandler:imageStreamHandler
                   forResultHandler:^(OSImageId *leftHandImageId, OSImageId *rightHandImageId) {
                     OSTuple<OSImageId *, OSImageId *> *tuple = [OSTuple tupleWithFirst:leftHandImageId
                                                                              andSecond:rightHandImageId];
                     [tuples addObject:tuple];
                   }];
    return tuples;
}

- (NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImagesWithProvider:(OSImageHashingProviderId)imageHashingProviderId
                                                  withHashDistanceThreshold:(OSHashDistanceType)hashDistanceThreshold
                                                                  forImages:(NSArray<OSTuple<OSImageId *, NSData *> *> *)imageTuples
{
    NSAssert(imageTuples, @"Image tuple array must not be nil");
    NSUInteger __block i = 0;
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *result = [self
        similarImagesWithProvider:imageHashingProviderId
        withHashDistanceThreshold:hashDistanceThreshold
            forImageStreamHandler:^OSTuple<OSImageId *, NSData *> *{
              if (i >= [imageTuples count]) {
                  return nil;
              }
              OSTuple<OSImageId *, NSData *> *tuple = imageTuples[i];
              i++;
              return tuple;
            }];
    return result;
}

#pragma mark - Result Conversion

- (NSDictionary<OSImageId *, NSSet<OSImageId *> *> *)dictionaryFromSimilarImagesResult:(NSArray<OSTuple<OSImageId *, OSImageId *> *> *)similarImageTuples
{
    NSAssert(similarImageTuples, @"Similar image tuple array must not be nil");
    NSMutableDictionary<OSImageId *, OSImageId *> *representatives = [NSMutableDictionary new];
    NSMutableDictionary<OSImageId *, NSMutableSet<OSImageId *> *> *result = [NSMutableDictionary new];
    for (OSTuple<OSImageId *, OSImageId *> *tuple in similarImageTuples) {
        OSImageId *first = tuple.first;
        OSImageId *second = tuple.second;
        if (first && second) {
            OSImageId *firstRep = representatives[first];
            if (!firstRep) {
                representatives[first] = firstRep = first;
                result[first] = [NSMutableSet set];
            }
            OSImageId *secondRep = representatives[second];
            if (!secondRep) {
                representatives[second] = firstRep;
            }
            [result[firstRep] addObject:second];
        }
    }
    return result;
}

@end
