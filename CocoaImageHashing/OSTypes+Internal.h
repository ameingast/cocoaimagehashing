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

