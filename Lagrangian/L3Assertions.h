//  L3Assertions.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"
#import "L3AssertionReference.h"

#define l3_assertionReference(_subject, _subjectSource, _patternSource) \
	[L3AssertionReference assertionReferenceWithFile:@"" __FILE__ line:__LINE__ subjectSource:@"" _subjectSource subject:_subject patternSource:@"" _patternSource]

#define l3_assert(subject, pattern) \
	^bool{ \
		id subject_ = l3_to_object(subject); \
		L3Pattern pattern_ = l3_to_pattern(pattern); \
		return [_case assertThat:subject_ matches:pattern_ assertionReference:l3_assertionReference(subject_, #subject, #pattern) eventAlgebra:_case.eventAlgebra]; \
	}()

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
