//  L3Types.h
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestCase;
@class L3TestSuite;
@class L3TestState;

#pragma mark -
#pragma mark Test functions

typedef void(*L3TestCaseFunction)(L3TestState *, L3TestSuite *, L3TestCase *);
typedef L3TestCaseFunction L3TestCaseSetUpFunction;
typedef L3TestCaseFunction L3TestCaseTearDownFunction;

typedef void(^L3TestCaseBlock)(L3TestState *, L3TestSuite *, L3TestCase *);


#pragma mark -
#pragma mark Assert patterns

typedef bool(^L3Pattern)(id);


#pragma mark -
#pragma mark Object conversion

#import "L3PreprocessorUtilities.h"

// start off by assuming all conversions to be unavailable (is this necessary?)
static inline id l3_to_object(...) __attribute__((overloadable, unavailable));

#define l3_define_to_object_by_boxing_with_type(type) \
	__attribute__((overloadable)) static inline id l3_to_object(type x) { return @(x); };

// box these types automatically
l3_fold(l3_define_to_object_by_boxing_with_type,
		uint64_t, uint32_t, uint16_t, uint8_t, int64_t, int32_t, int16_t, int8_t, double, float, bool, char *)
__attribute__((overloadable)) static inline id l3_to_object(id x) { return x; }
