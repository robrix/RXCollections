//  RXInterval.h
//  Created by Rob Rix on 2013-03-01.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#define RX_MAGNITUDE_IS_DOUBLE 0
#define RX_MAGNITUDE_MAX FLT_MAX
#import <RXCollections/RXMagnitude.h>
}


#pragma mark RXInterval

@protocol RXInterval <NSObject, RXEnumerable>
@property (nonatomic, readonly) RXMagnitude from;
@property (nonatomic, readonly) RXMagnitude to;
@property (nonatomic, readonly) RXMagnitude length;
@property (nonatomic, readonly) RXMagnitude stride;
@property (nonatomic, readonly) NSUInteger count;
@end

extern id<RXInterval> RXInterval(RXMagnitude from, RXMagnitude to); // implicit stride of 1
extern id<RXInterval> RXIntervalByStride(RXMagnitude from, RXMagnitude to, RXMagnitude stride);
extern id<RXInterval> RXIntervalByCount(RXMagnitude from, RXMagnitude to, NSUInteger count);

static inline RXMagnitude RXIntervalGetLength(RXMagnitude from, RXMagnitude to);

static inline RXMagnitude RXIntervalGetLength(RXMagnitude from, RXMagnitude to) {
	return RXMagnitudeGetAbsoluteValue(to - from);
}
