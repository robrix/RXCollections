//  L3Assertions.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Types.h>
#import <Lagrangian/L3SourceReference.h>

#pragma mark Assertions

#define l3_sourceReference(_subject, _subjectSource, _patternSource) \
	[L3SourceReference referenceWithFile:@"" __FILE__ line:__LINE__ subjectSource:@"" _subjectSource subject:_subject patternSource:@"" _patternSource]

#define l3_assert(subject, pattern) \
	^bool{ \
		id subject_ = l3_to_object(subject); \
		L3Pattern pattern_ = l3_to_pattern(pattern); \
		return [self assertThat:subject_ matches:pattern_ sourceReference:l3_sourceReference(subject_, #subject, #pattern) eventObserver:test.eventObserver]; \
	}()


#pragma mark Equality patterns

#define l3_not(...) \
	(^bool(id x){ return !l3_to_pattern(__VA_ARGS__)(x); })

#define l3_is(...)						(__VA_ARGS__)
#define l3_equalTo(...)					(__VA_ARGS__)
#define l3_equals(...)					(__VA_ARGS__)
#define l3_equalsWithEpsilon(x, y)		l3_to_pattern_f(x, y)


#pragma mark Classification patterns

#define l3_isKindOfClass(class) \
	(^bool(id x){ return [x isKindOfClass:class]; })


#pragma mark Comparison patterns

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


#pragma mark Asynchrony

// there is no race condition between waiting and completing a test, but if you are not waiting explicitly, you must defer the test for it to succeed

// l3_defer() is used to say that a test may complete after the test case returns
#define l3_defer()						[test deferCompletion]

// l3_wait is used to explicitly wait until the completion signal has been received, with a default timeout of five seconds
#define l3_wait()						[test wait]

// l3_wait_with_timeout allows you to specify the timeout explicitly
#define l3_wait_with_timeout(x)			[test waitWithTimeout:x]

// l3_complete signals the completion of the asynchronous portion of the test
#define l3_complete()					[test complete]

#define l3_did_not_timeout()			l3_equals(YES)
