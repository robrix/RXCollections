// RXAssertions.m
// Created by Rob Rix on 2011-08-20
// Copyright 2011 Decimus Software, Inc.

#import <math.h>
#import "RXAssertions.h"

static NSMutableDictionary *RXAssertionHelperComparisonFunctions = nil;
static NSMutableDictionary *RXAssertionHelperDescriptionFunctions = nil;

static double RXAssertionHelperFloatingPointComparisonAccuracy = 0.0;

BOOL RXAssertionHelperInt8Comparison(const void *a, const void *b) {
	return (*(RXCast(a, const uint8_t *))) == (*(RXCast(b, const uint8_t *)));
}

BOOL RXAssertionHelperInt16Comparison(const void *a, const void *b) {
	return (*(RXCast(a, const uint16_t *))) == (*(RXCast(b, const uint16_t *)));
}

BOOL RXAssertionHelperInt32Comparison(const void *a, const void *b) {
	return (*(RXCast(a, const uint32_t *))) == (*(RXCast(b, const uint32_t *)));
}

BOOL RXAssertionHelperInt64Comparison(const void *a, const void *b) {
	return (*(RXCast(a, const uint64_t *))) == (*(RXCast(b, const uint64_t *)));
}

BOOL RXAssertionHelperFloatComparison(const void *a, const void *b) {
	double _a = *RXCast(a, const float *), _b = *RXCast(b, const float *);
	return islessequal(MAX(_a, _b) - MIN(_a, _b), RXAssertionHelperFloatingPointComparisonAccuracy);
}

BOOL RXAssertionHelperDoubleComparison(const void *a, const void *b) {
	double _a = *RXCast(a, const double *), _b = *RXCast(b, const double *);
	return islessequal(MAX(_a, _b) - MIN(_a, _b), RXAssertionHelperFloatingPointComparisonAccuracy);
}

BOOL RXAssertionHelperObjectComparison(const void *a, const void *b) {
	const id _a = *RXCast(a, const id *), _b = *RXCast(b, const id *);
	return (_a == _b) || [_a isEqual: _b];
}

BOOL RXAssertionHelperCFTypeRefComparison(const void *a, const void *b) {
	CFTypeRef _a = *RXCast(a, CFTypeRef *), _b = *RXCast(b, CFTypeRef *);
	return
		(_a == _b)
	||	((_a != nil) && (_b != nil) && CFEqual(_a, _b));
}

BOOL RXAssertionHelperNSPointComparison(const void *a, const void *b) {
	return NSEqualPoints(*RXCast(a, const NSPoint *), *RXCast(b, const NSPoint *));
}

BOOL RXAssertionHelperNSRangeComparison(const void *a, const void *b) {
	return NSEqualRanges(*RXCast(a, const NSRange *), *RXCast(b, const NSRange *));
}


NSString *RXAssertionHelperHexadecimalDescription(const void *ref) {
	return [NSString stringWithFormat: @"%x", *RXCast(ref, const void **)];
}

NSString *RXAssertionHelperInt8Description(const void *ref) {
	return [NSString stringWithFormat: @"%d", *RXCast(ref, const int8_t *)];
}

NSString *RXAssertionHelperUInt8Description(const void *ref) {
	return [NSString stringWithFormat: @"%u", *RXCast(ref, const uint8_t *)];
}

NSString *RXAssertionHelperInt16Description(const void *ref) {
	return [NSString stringWithFormat: @"%d", *RXCast(ref, const int16_t *)];
}

NSString *RXAssertionHelperUInt16Description(const void *ref) {
	return [NSString stringWithFormat: @"%u", *RXCast(ref, const uint16_t *)];
}

NSString *RXAssertionHelperInt32Description(const void *ref) {
	return [NSString stringWithFormat: @"%d", *RXCast(ref, const int32_t *)];
}

NSString *RXAssertionHelperUInt32Description(const void *ref) {
	return [NSString stringWithFormat: @"%u", *RXCast(ref, const uint32_t *)];
}

NSString *RXAssertionHelperInt64Description(const void *ref) {
	return [NSString stringWithFormat: @"%qi", *RXCast(ref, const int64_t *)];
}

NSString *RXAssertionHelperUInt64Description(const void *ref) {
	return [NSString stringWithFormat: @"%qu", *RXCast(ref, const uint64_t *)];
}

NSString *RXAssertionHelperFloatDescription(const void *ref) {
	return [NSString stringWithFormat: @"%f", *RXCast(ref, const float *)];
}

NSString *RXAssertionHelperDoubleDescription(const void *ref) {
	return [NSString stringWithFormat: @"%f", *RXCast(ref, const double *)];
}

NSString *RXAssertionHelperObjectDescription(const void *ref) {
	return [NSString stringWithFormat: @"%@", *RXCast(ref, const id *)];
}

//NSString *RXAssertionHelperCFTypeRefDescription(const void *ref) {
//	CFTypeRef _ref = *RXCast(ref, CFTypeRef *);
//	return _ref ? [(__bridge id)_ref description] : @"(null)";
//}

NSString *RXAssertionHelperNSPointDescription(const void *ref) {
	return NSStringFromPoint(*RXCast(ref, const NSPoint *));
}

NSString *RXAssertionHelperNSRangeDescription(const void *ref) {
	return NSStringFromRange(*RXCast(ref, const NSRange *));
}


@implementation RXAssertionHelper

+(void)initialize {
	if(!RXAssertionHelperComparisonFunctions) {
		RXAssertionHelperComparisonFunctions = [[NSMutableDictionary alloc] init];
	}
	if(!RXAssertionHelperDescriptionFunctions) {
		RXAssertionHelperDescriptionFunctions = [[NSMutableDictionary alloc] init];
	}
	
#ifdef __LP64__
	[self registerComparisonFunction: RXAssertionHelperInt64Comparison forObjCType: @encode(void *)];
#else
	[self registerComparisonFunction: RXAssertionHelperInt32Comparison forObjCType: @encode(void *)];
#endif
	[self registerComparisonFunction: RXAssertionHelperInt8Comparison forObjCType: @encode(int8_t)];
	[self registerComparisonFunction: RXAssertionHelperInt8Comparison forObjCType: @encode(uint8_t)];
	[self registerComparisonFunction: RXAssertionHelperInt16Comparison forObjCType: @encode(int16_t)];
	[self registerComparisonFunction: RXAssertionHelperInt16Comparison forObjCType: @encode(uint16_t)];
	[self registerComparisonFunction: RXAssertionHelperInt32Comparison forObjCType: @encode(int32_t)];
	[self registerComparisonFunction: RXAssertionHelperInt32Comparison forObjCType: @encode(uint32_t)];
	[self registerComparisonFunction: RXAssertionHelperInt64Comparison forObjCType: @encode(int64_t)];
	[self registerComparisonFunction: RXAssertionHelperInt64Comparison forObjCType: @encode(uint64_t)];
	[self registerComparisonFunction: RXAssertionHelperFloatComparison forObjCType: @encode(float)];
	[self registerComparisonFunction: RXAssertionHelperDoubleComparison forObjCType: @encode(double)];
	[self registerComparisonFunction: RXAssertionHelperObjectComparison forObjCType: @encode(id)];
	[self registerComparisonFunction: RXAssertionHelperObjectComparison forObjCType: @encode(Class)];
	CFStringRef string = NULL;
	CFArrayRef array = NULL;
	CFCharacterSetRef characterSet = NULL;
	[self registerComparisonFunction: RXAssertionHelperCFTypeRefComparison forObjCType: @encode(__typeof__(string))]; // __typeof__ keeps qualifiers, e.g. const
	[self registerComparisonFunction: RXAssertionHelperCFTypeRefComparison forObjCType: @encode(__typeof__(array))]; // __typeof__ keeps qualifiers, e.g. const
	[self registerComparisonFunction: RXAssertionHelperCFTypeRefComparison forObjCType: @encode(__typeof__(characterSet))]; // __typeof__ keeps qualifiers, e.g. const
	[self registerComparisonFunction: RXAssertionHelperNSPointComparison forObjCType: @encode(NSPoint)];
	[self registerComparisonFunction: RXAssertionHelperNSPointComparison forObjCType: @encode(CGPoint)];
	[self registerComparisonFunction: RXAssertionHelperNSRangeComparison forObjCType: @encode(NSRange)];
	
	[self registerDescriptionFunction: RXAssertionHelperHexadecimalDescription forObjCType: @encode(void *)];
	[self registerDescriptionFunction: RXAssertionHelperInt8Description forObjCType: @encode(int8_t)];
	[self registerDescriptionFunction: RXAssertionHelperUInt8Description forObjCType: @encode(uint8_t)];
	[self registerDescriptionFunction: RXAssertionHelperInt16Description forObjCType: @encode(int16_t)];
	[self registerDescriptionFunction: RXAssertionHelperUInt16Description forObjCType: @encode(uint16_t)];
	[self registerDescriptionFunction: RXAssertionHelperInt32Description forObjCType: @encode(int32_t)];
	[self registerDescriptionFunction: RXAssertionHelperUInt32Description forObjCType: @encode(uint32_t)];
	[self registerDescriptionFunction: RXAssertionHelperInt64Description forObjCType: @encode(int64_t)];
	[self registerDescriptionFunction: RXAssertionHelperUInt64Description forObjCType: @encode(uint64_t)];
	[self registerDescriptionFunction: RXAssertionHelperFloatDescription forObjCType: @encode(float)];
	[self registerDescriptionFunction: RXAssertionHelperDoubleDescription forObjCType: @encode(double)];
	[self registerDescriptionFunction: RXAssertionHelperObjectDescription forObjCType: @encode(id)];
	[self registerDescriptionFunction: RXAssertionHelperObjectDescription forObjCType: @encode(Class)];
//	[self registerDescriptionFunction: RXAssertionHelperCFTypeRefDescription forObjCType: @encode(__typeof__(string))]; // __typeof__ keeps qualifiers, e.g. const
//	[self registerDescriptionFunction: RXAssertionHelperCFTypeRefDescription forObjCType: @encode(__typeof__(array))]; // __typeof__ keeps qualifiers, e.g. const
//	[self registerDescriptionFunction: RXAssertionHelperCFTypeRefDescription forObjCType: @encode(__typeof__(characterSet))]; // __typeof__ keeps qualifiers, e.g. const
	[self registerDescriptionFunction: RXAssertionHelperNSPointDescription forObjCType: @encode(NSPoint)];
	[self registerDescriptionFunction: RXAssertionHelperNSPointDescription forObjCType: @encode(CGPoint)];
	[self registerDescriptionFunction: RXAssertionHelperNSRangeDescription forObjCType: @encode(NSRange)];
}


+(NSString *)keyForObjCType:(const char *)type {
	return [NSString stringWithFormat: @"%s", type];
}

+(RXAssertionHelperComparisonFunction)comparisonFunctionForObjCType:(const char *)type {
	return [[RXAssertionHelperComparisonFunctions objectForKey: [self keyForObjCType: type]] pointerValue];
}

+(void)registerComparisonFunction:(RXAssertionHelperComparisonFunction)comparator forObjCType:(const char *)type {
	[RXAssertionHelperComparisonFunctions setObject: [NSValue valueWithPointer: comparator] forKey: [self keyForObjCType: type]];
}

+(BOOL)compareValue:(const void *)aRef withValue:(const void *)bRef ofObjCType:(const char *)type {
	RXAssertionHelperComparisonFunction function =
		[self comparisonFunctionForObjCType: type]
	?:
#ifdef __LP64__
		RXAssertionHelperInt64Comparison;
#else
		RXAssertionHelperInt32Comparison;
#endif
	return function(aRef, bRef);
}


+(RXAssertionHelperDescriptionFunction)descriptionFunctionForObjCType:(const char *)type {
	return [[RXAssertionHelperDescriptionFunctions objectForKey: [self keyForObjCType: type]] pointerValue];
}

+(void)registerDescriptionFunction:(RXAssertionHelperDescriptionFunction)descriptor forObjCType:(const char *)type {
	[RXAssertionHelperDescriptionFunctions setObject: [NSValue valueWithPointer: descriptor] forKey: [self keyForObjCType: type]];
}

+(NSString *)descriptionForValue:(const void *)ref ofObjCType:(const char *)type {
	RXAssertionHelperDescriptionFunction function = [self descriptionFunctionForObjCType: type] ?: RXAssertionHelperHexadecimalDescription;
	return function(ref);
}


+(double)floatingPointComparisonAccuracy {
	return RXAssertionHelperFloatingPointComparisonAccuracy;
}

+(void)setFloatingPointComparisonAccuracy:(double)epsilon {
	RXAssertionHelperFloatingPointComparisonAccuracy = epsilon;
}


+(NSString *)humanReadableNameForTestCaseSelector:(SEL)selector {
	NSMutableArray *words = [NSMutableArray array];
	NSScanner *scanner = [NSScanner scannerWithString: NSStringFromSelector(selector)];
	[scanner scanString: @"test" intoString: nil]; // skip "test"
	while(!scanner.isAtEnd) {
		NSString *up = nil, *lo = nil;
		NSUInteger cursor = scanner.scanLocation;
		up = [scanner.string substringWithRange: NSMakeRange(cursor, 1)]; // grab the first character
		scanner.scanLocation = cursor + 1;
		[scanner scanCharactersFromSet: [NSCharacterSet lowercaseLetterCharacterSet] intoString: &lo];
		[words addObject: [NSString stringWithFormat: @"%@%@", [up lowercaseString], lo ?: @""]];
	}
	return [words componentsJoinedByString: @" "];
}

+(NSString *)humanReadableNameForTestSuiteClass:(Class)klass {
	NSString *name = NSStringFromClass(klass);
	NSString *result = name;
	NSRange testsRange = [name rangeOfString: @"Tests" options: NSBackwardsSearch | NSAnchoredSearch];
	NSRange testRange = [name rangeOfString: @"Test" options: NSBackwardsSearch | NSAnchoredSearch];
	if(testsRange.location != NSNotFound) {
		result = [name substringToIndex: testsRange.location];
	} else if(testRange.location != NSNotFound) {
		result = [name substringToIndex: testRange.location];
	}
	return result;
}

@end


@implementation SenTestCase (RXAssertionsPrettierNamesForTestCases)

//-(NSString *)name {
//	return [NSString stringWithFormat: @"%@ %@", [RXAssertionHelper humanReadableNameForTestSuiteClass: self.class], [RXAssertionHelper humanReadableNameForTestCaseSelector: self.invocation.selector]];
//}

@end
