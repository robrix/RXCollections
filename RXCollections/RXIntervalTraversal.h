//  RXIntervalTraversal.h
//  Created by Rob Rix on 2013-03-01.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>
#import <float.h>

#if defined(__LP64__) && __LP64__
#define RX_MAGNITUDE_TYPE double
#define RX_MAGNITUDE_IS_DOUBLE 1
#define RX_MAGNITUDE_MIN DBL_MIN
#define RX_MAGNITUDE_MAX DBL_MAX
#else
#define RX_MAGNITUDE_TYPE float
#define RX_MAGNITUDE_IS_DOUBLE 0
#define RX_MAGNITUDE_MIN FLT_MIN
#define RX_MAGNITUDE_MAX FLT_MAX
#endif

typedef RX_MAGNITUDE_TYPE RXMagnitude;
#define RX_MAGNITUDE_DEFINED 1

@protocol RXInterval <NSObject, RXTraversable>
@property (nonatomic, readonly) RXMagnitude from;
@property (nonatomic, readonly) RXMagnitude to;
@property (nonatomic, readonly) RXMagnitude length;
@property (nonatomic, readonly) RXMagnitude stride;
@property (nonatomic, readonly) NSUInteger count;
@end

extern id<RXInterval> RXInterval(RXMagnitude from, RXMagnitude to); // implicit stride of 1
extern id<RXInterval> RXIntervalByStride(RXMagnitude from, RXMagnitude to, RXMagnitude stride);
extern id<RXInterval> RXIntervalByCount(RXMagnitude from, RXMagnitude to, NSUInteger count);


#pragma mark RXMagnitude

static inline RXMagnitude RXMagnitudeGetAbsoluteValue(RXMagnitude x);

static inline RXMagnitude RXMagnitudeGetAbsoluteValue(RXMagnitude x) {
#if RX_MAGNITUDE_IS_DOUBLE
	return fabs(x);
#else
	return fabsf(x);
#endif
}


#pragma mark RXInterval

static inline RXMagnitude RXIntervalGetLength(RXMagnitude from, RXMagnitude to);

static inline RXMagnitude RXIntervalGetLength(RXMagnitude from, RXMagnitude to) {
	return RXMagnitudeGetAbsoluteValue(to - from);
}
