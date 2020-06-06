# CocoaImageHashing

[![build Status](https://api.travis-ci.org/ameingast/cocoaimagehashing.png)](https://travis-ci.org/ameingast/cocoaimagehashing)
[![carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codecov](http://codecov.io/github/ameingast/cocoaimagehashing/coverage.svg?branch=master)](http://codecov.io/github/ameingast/cocoaimagehashing?branch=master)
[![license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
![platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg?longCache=true&style=flat)
[![donate](https://img.shields.io/badge/donate-paypal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=E5NS7AQG7EN8J)

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

This framework was written for macOS, iOS, watchOS and tvOS. This means 
that basic image transformations are executed through CoreGraphics. 
There are no external dependencies, so getting the framework integrated 
into your project is straight-forward.

This framework provides three hashing functions with the following properties:

|Name|Performance|Quality|
|:-:|:-:|:-:|
|aHash|good|bad|
|dHash|excellent|good|
|pHash|bad|excellent|

### Performance

Depending on the hashing algorithm, perceptual hashing generally can yield
very good performance. This library was built primarily for ease of use, but
hashing performance was critical, too. Some utility functions have data parallelism
built in and fingerprint calculation makes use of current CPU instruction pipelines by
unrolling and inlining all tight loops of used hashing algorithms.

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
github "ameingast/cocoaimagehashing" ~> 1.8.0
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

```swift
import CocoaImageHashing

let firstImageData = Data()
let secondImageData = Data()
let result = OSImageHashing.sharedInstance().compareImageData(firstImageData,
                                                              to: secondImageData,
                                                              with: .pHash)
print("Match", result)
```

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

```swift
import CocoaImageHashing

let lhsData = OSImageHashing.sharedInstance().hashImageData(Data(), with: .pHash)
let rhsData = OSImageHashing.sharedInstance().hashImageData(Data(), with: .pHash)
let result = OSImageHashing.sharedInstance().hashDistance(lhsData, to: rhsData, with: .pHash)
print("Distance", result)
```

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

```swift
import CocoaImageHashing

var imageData = [Data(), Data(), Data()]
let similarImages = imageHashing.similarImages(withProvider: .pHash) {
    if imageData.count > 0 {
        let data = imageData.removeFirst()
        return OSTuple<NSString, NSData>(first: name as NSString, 
                                         andSecond: data as NSData)
    } else {
        return nil
    }
}
print("Similar Images", similarImages)
```

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

```swift
import CocoaImageHashing

let baseImage = Data()
let images = [Data(), Data(), Data()]
let sortedImages = imageHashing.sortedArray(usingImageSimilartyComparator: baseImage, 
                                            for: images, 
                                            for: .pHash)
print("Sorted images", sortedImages)
```

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

More examples can be found in the test suite and the project playground.

## Contact and Contributions

Please submit bug reports and improvements through pull-requests or 
tickets on github.

This project uses conservative compiler settings. Please be sure 
that no compiler warnings occur before sending patchesor pull 
requests upstream.

If you like this library, please consider donating. Thank you!

## Copyright and Licensensing

Copyright (c) 2015, Andreas Meingast <ameingast@gmail.com>.

The framework is published under a BSD style license. For more information,
please see the LICENSE file.
