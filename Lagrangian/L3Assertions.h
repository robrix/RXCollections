//  L3Assertions.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"
#import "L3AssertionReference.h"

#define l3_assertionReference(subject, pattern) \
	[L3AssertionReference assertionWithFile:@"" __FILE__ line:__LINE__ subjectSource:@"" #subject patternSource:@"" #pattern]

#define l3_assert(subject, pattern) \
	[_case assertThat:l3_to_object(subject) matches:l3_to_pattern(pattern) assertionReference:l3_assertionReference(subject, pattern) collectingEventsInto:_case.eventSink]

#define l3_not(pattern)				(^bool(id x){ return !l3_to_pattern(pattern)(x); })

#define l3_is(pattern)				pattern
#define l3_equalTo(pattern)			pattern
#define l3_equals(pattern)			pattern

#define l3_isKindOfClass(class) \
	(^bool(id x){ return [x isKindOfClass:class]; })

#define l3_ordered(object, ordering) \
	(^bool(id x){ return [x compare:l3_to_object(object)] == ordering; })
#define l3_ordered_or_same(object, ordering) \
	(^bool(id x){ NSComparisonResult comparison = [x compare:l3_to_object(object)]; return (comparison == ordering) || (comparison == NSOrderedSame); })
#define l3_greaterThan(object)		l3_ordered(object, NSOrderedDescending)
#define l3_greaterThanOrEqualTo(object) \
	l3_ordered_or_same(object, NSOrderedDescending)
#define l3_lessThan(object)			l3_ordered(object, NSOrderedAscending)
#define l3_lessThanOrEqualTo(object) \
	l3_ordered_or_same(object, NSOrderedAscending)
