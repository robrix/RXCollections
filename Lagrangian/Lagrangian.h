//  Lagrangian.h
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3TestSuite.h"

#pragma mark -
#pragma mark Test suites

#define l3suite(str) \
	class L3TestSuite; \
	static L3TestSuite *l3identifier(test_suite_builder_, __LINE__)(); \
	__attribute__((constructor)) static void l3identifier(test_suite_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			l3current_suite = l3identifier(test_suite_builder_, __LINE__)();\
		} \
	} \
	static L3TestSuite *l3identifier(test_suite_builder_, __LINE__)() { \
		static L3TestSuite *suite = nil; \
		static dispatch_once_t onceToken; \
		dispatch_once(&onceToken, ^{ \
			suite = [L3TestSuite suiteWithName:@(str)]; \
		}); \
		return suite; \
	}


#pragma mark -
#pragma mark Test cases

#define l3test(str) \
	class L3TestSuite, L3TestCase; \
	\
	static void l3identifier(test_case_impl_, __LINE__)(L3TestSuite *suite, L3TestCase *self); \
	static L3TestCase *l3identifier(test_case_builder_, __LINE__)(L3TestSuite *suite); \
	\
	__attribute__((constructor)) static void l3identifier(test_case_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			\
			[l3current_suite addTestCase:l3identifier(test_case_builder_, __LINE__)(nil)]; \
		} \
	} \
	static L3TestCase *l3identifier(test_case_builder_, __LINE__)(L3TestSuite *suite) { \
		return nil; \
	} \
	static void l3identifier(test_case_impl_, __LINE__)(L3TestSuite *suite, L3TestCase *self)



#pragma mark -
#pragma mark Macro utilities

#define l3domain						com_antitypical_lagrangian_
#define l3identifier(sym, line)			l3paste(l3paste(l3domain, sym), line)
#define l3current_suite					l3paste(l3domain, current_suite)

#define l3paste(a, b)					l3paste_implementation(a, b)
#define l3paste_implementation(a, b)	a##b

static L3TestSuite *l3current_suite = nil;