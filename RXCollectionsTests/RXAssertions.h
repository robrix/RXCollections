// RXAssertions.h
// Created by Rob Rix on 2011-08-20
// Copyright 2011 Decimus Software, Inc.

#import <SenTestingKit/SenTestingKit.h>

// Assertion macros that don’t require you to describe the assertion. Perfect for use with intention-revealing code.

// Don’t use this unless you’re writing your own assertions. The first argument is ignored, so the assertions can have optional messages appended to them without suffering a compiler error.
#define RXOptionalMessageString(ignored, format, ...) [NSString stringWithFormat: (format), ## __VA_ARGS__]

#define RXAssert(_expression, ...) do {\
	__typeof__(_expression) __condition = (_expression);\
	if(!__condition)\
		STFail(RXOptionalMessageString(, ## __VA_ARGS__, @"%s was unexpectedly false.", #_expression));\
} while(0)
#define RXAssertFalse(_expression, ...) do {\
	__typeof__(_expression) __condition = (_expression);\
	if(__condition)\
		STFail(RXOptionalMessageString(, ## __VA_ARGS__, @"%s was unexpectedly true.", #_expression));\
} while(0)

// casts the expected value to the type of the actual value. will fail (and rightly so) if you try crazy casts like struct to pointer.
#define RXAssertEquals(_actual, _expected, ...) do {\
	__typeof__(_actual) __actual = (_actual), __expected = (__typeof__(__actual))(_expected);\
	if(![RXAssertionHelper compareValue: &__actual withValue: &__expected ofObjCType: @encode(__typeof__(__actual))]) {\
		STFail(@"%s has value %@, not expected value %@. %@", #_actual, [RXAssertionHelper descriptionForValue: &__actual ofObjCType: @encode(__typeof__(__actual))], [RXAssertionHelper descriptionForValue: &__expected ofObjCType: @encode(__typeof__(__actual))], RXOptionalMessageString(, ## __VA_ARGS__, @""));\
	}\
} while(0)
#define RXAssertNotEquals(_actual, _expected, ...) do {\
	__typeof__(_actual) __actual = (_actual), __expected = (__typeof__(__actual))(_expected);\
	if([RXAssertionHelper compareValue: &__actual withValue: &__expected ofObjCType: @encode(__typeof__(__actual))]) {\
		STFail(@"%s has unexpected value %@. %@", #_actual, [RXAssertionHelper descriptionForValue: &__actual ofObjCType: @encode(__typeof__(__actual))], RXOptionalMessageString(, ## __VA_ARGS__, @""));\
	}\
} while(0)

#define RXAssertNil(_thing, ...) do {\
	__typeof__(_thing) __thing = (_thing);\
	if(__thing != nil) STFail(RXOptionalMessageString(, ## __VA_ARGS__, @"%s was unexpectedly %@, not nil.", #_thing, __thing));\
} while(0)
#define RXAssertNotNil(_thing, ...) do {\
	if((_thing) == nil) STFail(RXOptionalMessageString(, ## __VA_ARGS__, @"%s was unexpectedly nil.", #_thing));\
} while(0)


//#ifdef __clang__
#if 0
	// this is bad, as strict aliasing will break it, but clang doesn’t handle union casts correctly
	#define RXCast(x, toType) *(toType *)&(x)
#else
	#define RXCast(x, toType) (((union{__typeof__(x) a; toType b;})x).b)
#endif
#define RXRound(value, place) (round((value) / (place)) * (place))


typedef BOOL (*RXAssertionHelperComparisonFunction)(const void *aRef, const void *bRef);
typedef NSString *(*RXAssertionHelperDescriptionFunction)(const void *ref);


// making these functions available for registering Polymorph types
BOOL RXAssertionHelperObjectComparison(const void *a, const void *b);
NSString *RXAssertionHelperObjectDescription(const void *ref);

BOOL RXAssertionHelperCFTypeRefComparison(const void *a, const void *b);
NSString *RXAssertionHelperCFTypeRefDescription(const void *ref);


@interface RXAssertionHelper : NSObject

+(void)registerComparisonFunction:(RXAssertionHelperComparisonFunction)comparator forObjCType:(const char *)type;
+(BOOL)compareValue:(const void *)aRef withValue:(const void *)bRef ofObjCType:(const char *)type;

+(void)registerDescriptionFunction:(RXAssertionHelperDescriptionFunction)descriptor forObjCType:(const char *)type;
+(NSString *)descriptionForValue:(const void *)ref ofObjCType:(const char *)type;

+(double)floatingPointComparisonAccuracy;
+(void)setFloatingPointComparisonAccuracy:(double)epsilon;

// returns a nicely formatted name for the test case selector
+(NSString *)humanReadableNameForTestCaseSelector:(SEL)selector;

@end
