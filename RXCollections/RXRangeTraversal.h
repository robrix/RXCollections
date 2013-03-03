//  RXRangeTraversal.h
//  Created by Rob Rix on 2013-03-01.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXTraversal.h"

extern id<RXTraversal> RXRange(NSInteger from, NSInteger to);


@interface RXRangeTraversal : NSObject <RXTraversal>

+(instancetype)traversalFromInteger:(NSInteger)from toInteger:(NSInteger)to byStrideWithMagnitude:(NSUInteger)magnitude;

@property (nonatomic, readonly) NSInteger from;
@property (nonatomic, readonly) NSInteger to;
@property (nonatomic, readonly) NSInteger stride;
@property (nonatomic, readonly) NSUInteger count;

@end
