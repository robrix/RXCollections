//  Lagrangian.h
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3TestCase.h"
#import "L3TestRunner.h"
#import "L3TestState.h"
#import "L3TestSuite.h"

#pragma mark -
#pragma mark Configuration macros

// L3_TESTS implies L3_DEBUG
#if L3_TESTS
#define L3_DEBUG 1
#endif

// DEBUG=1 implies L3_DEBUG
#if DEBUG
#define L3_DEBUG 1
#endif

#if L3_DEBUG
#endif

#if L3_RUN_TESTS_ON_LAUNCH
#endif


#pragma mark -
#pragma mark Test suites

#if L3_DEBUG

#define l3_suite(str) \
	class L3TestSuite; \
	static L3TestSuite *l3_identifier(test_suite_builder_, __LINE__)(); \
	__attribute__((constructor)) static void l3_identifier(test_suite_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			l3_current_suite = l3_identifier(test_suite_builder_, __LINE__)(); \
			[[L3TestRunner runner] addTestSuite:l3_current_suite]; \
		} \
	} \
	static L3TestSuite *l3_identifier(test_suite_builder_, __LINE__)() { \
		static L3TestSuite *suite = nil; \
		static dispatch_once_t onceToken; \
		dispatch_once(&onceToken, ^{ \
			suite = [L3TestSuite testSuiteWithName:@(str)]; \
		}); \
		return suite; \
	} \
	@class L3TestSuite

#define l3_suite_state(str) \
	l3_suite(str); \
	\
	@class l3_state_class; \
	\
	__attribute__((constructor)) static void l3_identifier(test_suite_state_class_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			l3_current_suite.onLoad = ^{ l3_current_suite.stateClass = [NSClassFromString(@"" l3_string(l3_state_class)) class]; };\
		} \
	} \
	\
	@interface l3_state_class : L3TestState \
	@end \
	\
	@interface l3_state_class () 

#else

#define l3_suite(str) \
	class NSObject;

#define l3_suite_state(str) \
	class NSObject; \
	@interface L3TestState (l3_identifier(test_state_dummy_category_, __COUNTER__))

#endif



#pragma mark -
#pragma mark Test cases

#if L3_DEBUG

#define l3_set_up \
	class L3TestSuite, L3TestCase; \
	\
	static void l3_identifier(set_up_, __LINE__)(l3_state_class *state, L3TestSuite *suite, L3TestCase *test); \
	\
	__attribute__((constructor)) static void l3_identifier(set_up_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			l3_current_suite.setUpFunction = l3_identifier(set_up_, __LINE__); \
		} \
	} \
	\
	static void l3_identifier(set_up_, __LINE__)(l3_state_class *state, L3TestSuite *suite, L3TestCase *test) 

#define l3_test(str) \
	class L3TestSuite, L3TestCase; \
	\
	static void l3_identifier(test_case_impl_, __LINE__)(l3_state_class *state, L3TestSuite *suite, L3TestCase *self); \
	static L3TestCase *l3_identifier(test_case_builder_, __LINE__)(); \
	\
	__attribute__((constructor)) static void l3_identifier(test_case_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			[l3_current_suite addTestCase:l3_identifier(test_case_builder_, __LINE__)(nil)]; \
		} \
	} \
	static L3TestCase *l3_identifier(test_case_builder_, __LINE__)() { \
		return [L3TestCase testCaseWithName:@(str) function:l3_identifier(test_case_impl_, __LINE__)]; \
	} \
	static void l3_identifier(test_case_impl_, __LINE__)(l3_state_class *state, L3TestSuite *suite, L3TestCase *self)

#else

#define l3_test(str) \
	class NSObject; \
	__attribute__((unused)) \
	static void l3_identifier(ignored_test_case_, __COUNTER__)(L3TestSuite *suite, L3TestCase *self)

#define l3_set_up \
	l3_test("")

#endif


#pragma mark -
#pragma mark Macro utilities

#define l3_domain						com_antitypical_lagrangian_
#define l3_identifier(sym, line)		l3_paste(l3_paste(l3_domain, sym), line)
#define l3_state_class					l3_identifier(test_state_class_, __func__)
#define l3_current_suite				l3_paste(l3_domain, current_suite)

#define l3_paste(a, b)					l3_paste_implementation(a, b)
#define l3_paste_implementation(a, b)	a##b

#define l3_string(x)					l3_string_implementation(x)
#define l3_string_implementation(x)		#x


#pragma mark -
#pragma mark Test state

#if L3_DEBUG

static L3TestSuite *l3_current_suite = nil;

#endif
