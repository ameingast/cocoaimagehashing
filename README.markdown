# CocoaImageHashing

[![Build Status](https://api.travis-ci.org/ameingast/cocoaimagehashing.png)](https://travis-ci.org/ameingast/cocoaimagehashing)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Hey there and welcome to *CocoaImageHashing*, a framework helping you with
[perceptual hashing](https://en.wikipedia.org/wiki/Perceptual_hashing).

## About Perceptual hashing

Perceptual hashing is the application of an algorithm to create a _fingerprint_
for a multimedia format (in this case pictures). Perceptual hash functions
have a useful property: small, semantically negligible changes on the input
data (e.g. changing contrast, size, format, compression, rotation) produce only small 
changes on the function output.

This makes perceptual hashing functions useful for:

* finding duplicate images or de-dupliation
* finding similar images or matching
* sorting an image set wrt a base image

This framework was written for Mac OS X and iOS. This means that basic image
transformations are executed through CoreGraphics. There are no external
dependencies, so getting the framework integrated into your project is
straight-forward.

This framework provides three hashing functions with the following properties:

|Name|Performance|Quality|
|:-:|:-:|:-:|
|aHash|good|bad|
|dHash|excellent|good|
|pHash|bad|excellent|

### Performance

Depending on the hashing algorithm, perceptual hashing generally can yield
very good performance. This library was built primarily for ease of use, but
hashing performance was critical, too.

Fingerprint calculation makes use of current CPU instruction pipelines by
unrolling and inlining all tight loops of used hashing algorithms.

On a Dual-Core 2.6GHz i5, the fastest hashing algorithm (dHash) achieves
a hashing throughput of up to 700MB/s and 30.0000 hash distance calculations
per second on 4 cores.

## How To Get Started

### Installation with CocoaPods

Integrating this framework with Cocoapods is straightforward.

Just declare this dependency in your Podfile:

```ruby
pod 'CocoaImageHashing', :git => 'https://github.com/ameingast/cocoaimagehashing.git'
```

### Installation with Carthage

To use [Carthage](https://github.com/Carthage/Carthage) (a more lightweight but more hands on package manager) just create a `Cartfile` with 

```ruby
github "ameingast/cocoaimagehashing" ~> 1.4.0
```

Then follow the [steps in the Carthage guide](https://github.com/Carthage/Carthage#getting-started) basically (for iOS):

* run `carthage update`
* drag the framework from Carthage/Build into Linked Frameworks on the General tab
* add `carthage copy-frameworks` to a `Run Scripts` phase

and you're done.  The [steps for Mac are very similar](https://github.com/Carthage/Carthage#getting-started).

### Using the Framework

#### API

The entrypoint for the framework is the class _OSImageHashing_.

It provides APIs for:

* perceptual hashing of images in NSData, NSImage and UIImage format 
  in different complexities depending on the used hashing algorithm 
  or desired outcome quality
* comparing calulcated fingerprints in O(1) time and space
* measuring distance between calculated fingerprints in O(1) time and space
* concurrently finding similar elements in NSArrays in O(n^2) time and
  O(n) space
* concurrently finding similar elements in data streams in O(n^2) time and
  (almost) O(1) space
* sorting NSArrays based on image similarity

The CocoaImageHashing API is described in detail in this
[file](CocoaImageHashing/OSImageHashing.h).

#### Types

The framework uses the following types in its API:

|Name|Bitsize|Description|
|:-:|:-:|:-:|
|OSHashType|64|The result or fingerprint of a perceptual hashing function|
|OSHashDistanceType|64|The distance between to fingerprints|
|OSImageHashingProviderId|16|The API representation of a hashing algorithm|
|OSImageHashingQuality|16|The API representation of a hashing algorithm described by its hashing quality|

More detailed information on types is available
[here](CocoaImageHashing/OSTypes.h).

#### Examples

##### Comparing two images for similarity:

```objective-c
#import <CocoaImageHashing/CocoaImageHashing.h>

@interface HashExample : NSObject

@end

@implementation HashExample

- (void)imageSimilarity
{
    NSData *firstImageData = [NSData new];
    NSData *secondImageData = [NSData new]
    BOOL result = [[OSImageHashing sharedInstance] compareImageData:firstImageData to:secondImageData];
    NSLog(@"Images match: %@", result ? @"Yes" : @"No");
}

@end
```

##### Measuring the distance between two fingerprints

```objective-c
#import <CocoaImageHashing/CocoaImageHashing.h>

@interface DistanceExample : NSObject

@end

@implementation DistanceExample

- (void)measureDistance
{
    NSData *firstImageData = [NSData new];
    NSData *secondImageData = [NSData new]
    OSHashDistanceType distance = [[OSImageHashing sharedInstance] hashDistance:firstImageData to:secondImageData];
    NSLog(@"Hash distance: %@", @(distance));
}

@end
```
##### Finding similar images

```objective-c
#import <CocoaImageHashing/CocoaImageHashing.h>

@interface DuplicationExample : NSObject

@end

@implementation DuplicationExample

- (void)findDuplicates
{
    NSData *firstImageData = [NSData new];
    NSData *secondImageData = [NSData new]
    NSData *thirdImageData = [NSData new];
    NSMutableArray<OSTuple<OSImageId *, NSData *> *> *data = [NSMutableArray new];
    NSUInteger i = 0;
    for (NSData *data in @[ firstImageData, secondImageData, thirdImageData ]) {
       OSTuple<OSImageId *, NSData *> *tuple = [OSTuple tupleWithFirst:[NSString stringWithFormat:@"%@", @(i++)] andSecond:data];
       [data addObject:tuple];
    }
    NSArray<OSTuple<OSImageId *, OSImageId *> *> *similarImageIdsAsTuples = [[OSImageHashing sharedInstance] similarImagesWithHashingQuality:OSImageHashingQualityHigh forImages:images];
    NSLog(@"Similar image ids: %@", similarImageIdsAsTuples);
}

@end
```

##### Sorting an NSArray containing image data

```objective-c
#import <CocoaImageHashing/CocoaImageHashing.h>

@interface SortingExample : NSObject

@end

@implementation SortingExample

- (void)sortImageData
{
    NSData *baseImage = [NSData new];
    NSData *firstImageData = [NSData new];
    NSData *secondImageData = [NSData new]
    NSData *thirdImageData = [NSData new];
    NSArray<NSData *> *images = @[ firstImageData, secondImageData, thirdImageData ];
    NSArray<NSData *> *sortedImages = [[OSImageHashing sharedInstance] sortedArrayUsingImageSimilartyComparator:baseImage forArray:images];
    NSLog(@"Sorted images: %@", sortedImages);
}

@end
```

More examples can be found in the test suite!

## Contact and Contributions

Please submit bug reports and improvements through pull-requests or 
tickets on github.

This project uses conservative compiler settings. Please be sure 
that no compiler warnings occur before sending patchesor pull 
requests upstream. 

Thank you!

## Copyright and Licensensing

Copyright (c) 2015, Andreas Meingast <ameingast@gmail.com>.

The framework is published under a BSD style license. For more information,
please see the LICENSE file.
