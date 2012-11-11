//  L3Assertions.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"

#define l3_assert(object, pattern)	[_case assertThat:l3_to_object(object) matches:l3_to_pattern(pattern) collectingEventsInto:nil]

#define l3_not(pattern)				(^bool(id x){ return !l3_to_pattern(pattern)(x); })

#define l3_is(pattern)				pattern
#define l3_equalTo(pattern)			pattern
#define l3_equals(pattern)			pattern
