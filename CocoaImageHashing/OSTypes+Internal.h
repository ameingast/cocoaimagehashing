//
//  OSTypes+Internal.h
//  CocoaImageHashing
//

#import "OSTypes.h"

#pragma mark - Tuples

NS_ASSUME_NONNULL_BEGIN

@interface OSTuple<A, B> () {
    @public
    A __strong _Nullable _first;
    B __strong _Nullable _second;
}

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@interface OSHashResultTuple <A> () {
    @public
    A __strong _Nullable _first;
    OSHashType _hashResult;
}

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Utility Macros

#define OS_ALIGN(x, multiple) ({ __typeof__(x) m = (multiple) - 1; ((x) + m) & ~m; })

#pragma mark - Primitive Type Functions and Utilities

OS_INLINE OSHashDistanceType OSHammingDistance(OSHashType leftHand, OSHashType rightHand)
{
    return (OSHashDistanceType)__builtin_popcountll((UInt64)leftHand ^ (UInt64)rightHand);
}

NS_ASSUME_NONNULL_END

#pragma mark - Non-null Check Helpers

NS_ASSUME_NONNULL_BEGIN

/**
 * A workaround class to defeat CLANGs warnings for some GNU-extensions for C for null-checking.
 */
@interface OSNonNullHolder <__covariant Type>

- (Type)el;

@end

NS_ASSUME_NONNULL_END

#define OS_CAST_NONNULL(V)                  \
    ({                                      \
        OSNonNullHolder<__typeof(V)> *type; \
        (__typeof(type.el)) V;              \
    })
