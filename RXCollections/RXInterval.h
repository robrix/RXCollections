//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXMagnitude.h>
#import <RXCollections/RXBatchEnumerator.h>

typedef struct {
	RXMagnitude from;
	RXMagnitude to;
} RXInterval;

static inline RXInterval RXIntervalMakeWithLength(RXMagnitude from, RXMagnitude length) {
	return (RXInterval){
		.from = from,
		.to = from + length
	};
}

static inline RXMagnitude RXIntervalGetLength(RXInterval interval) {
	return RXMagnitudeGetAbsoluteValue(interval.to - interval.from);
}

@interface RXIntervalEnumerator : RXBatchEnumerator <RXFiniteEnumerator>

/**
 Implies a stride of 1.0.
 */
+(instancetype)enumeratorWithInterval:(RXInterval)interval;
+(instancetype)enumeratorWithInterval:(RXInterval)interval stride:(RXMagnitude)stride;
+(instancetype)enumeratorWithInterval:(RXInterval)interval count:(NSUInteger)count;

@property (nonatomic, readonly) RXInterval interval;

@property (nonatomic, readonly) RXMagnitude stride;
@property (nonatomic, readonly) NSUInteger count;

-(NSNumber *)nextObject;

@end
