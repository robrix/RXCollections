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

typedef struct RXInterval {
	RXMagnitude from;
	RXMagnitude to;
} RXInterval;


@interface RXIntervalTraversal : NSObject <RXTraversal>

+(instancetype)traversalWithInterval:(RXInterval)interval;
+(instancetype)traversalWithInterval:(RXInterval)interval stride:(RXMagnitude)stride;
+(instancetype)traversalWithInterval:(RXInterval)interval count:(NSUInteger)count;

@property (nonatomic, readonly) RXInterval interval;
@property (nonatomic, readonly) RXMagnitude length;
@property (nonatomic, readonly) RXMagnitude stride;
@property (nonatomic, readonly) NSUInteger count;

@end


static inline RXMagnitude RXMagnitudeGetAbsoluteValue(RXMagnitude x);

static inline RXInterval RXIntervalMake(RXMagnitude from, RXMagnitude to);
static inline RXInterval RXIntervalMakeWithLength(RXMagnitude from, RXMagnitude length);
static inline RXMagnitude RXIntervalGetLength(RXInterval interval);


#pragma mark RXMagnitude

static inline RXMagnitude RXMagnitudeGetAbsoluteValue(RXMagnitude x) {
#if RX_MAGNITUDE_IS_DOUBLE
	return fabs(x);
#else
	return fabsf(x);
#endif
}


#pragma mark RXInterval

static inline RXInterval RXIntervalMake(RXMagnitude from, RXMagnitude to) {
	return (RXInterval){ from, to };
}

static inline RXInterval RXIntervalMakeWithLength(RXMagnitude from, RXMagnitude length) {
	return (RXInterval){ from, from + length };
}

static inline RXMagnitude RXIntervalGetLength(RXInterval interval) {
	return RXMagnitudeGetAbsoluteValue(interval.to - interval.from);
}
