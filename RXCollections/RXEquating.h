//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

@protocol RXEquating <NSObject>

-(BOOL)isEqual:(id)object;

@end

static inline bool RXEqual(id<RXEquating> a, id<RXEquating> b) {
	return
		(a == b)
	||	[a isEqual:b];
}
static bool (* const RXEquals)(id<RXEquating>, id<RXEquating>) = RXEqual;


@interface NSObject (RXEquating) <RXEquating>
@end
