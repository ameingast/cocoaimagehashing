//
//  OSTypes+Internal.h
//  CocoaImageHashing
//

#import <CocoaImageHashing/OSTypes.h>

#pragma mark - Tuples

@interface OSTuple<A, B> () {
    @public
    A __strong _Nullable _first;
    B __strong _Nullable _second;
}

@end

@interface OSHashResultTuple <A> () {
    @public
    A __strong _Nullable _first;
    OSHashType _hashResult;
}

@end

#pragma mark - Primitive Type Functions and Utilities

OS_INLINE OSHashDistanceType OSHammingDistance(OSHashType leftHand, OSHashType rightHand)
{
    return (OSHashDistanceType)__builtin_popcountll((UInt64)leftHand ^ (UInt64)rightHand);
}

