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

#define l3_suite(str, ...) \
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
			suite = [L3TestSuite testSuiteWithName:@"" str]; \
			l3_cond(l3_count(__VA_ARGS__), suite.stateClass = NSClassFromString(@"" l3_string(l3_state_class(__VA_ARGS__))), {});\
		}); \
		return suite; \
	} \
	\
	@class l3_cond(l3_count(__VA_ARGS__), l3_state_class(__VA_ARGS__), L3TestState); \
	static l3_cond(l3_count(__VA_ARGS__), l3_state_class(__VA_ARGS__), L3TestState) *l3_state_class_variable; \
	\
	l3_cond(l3_count(__VA_ARGS__), @interface l3_state_class(__VA_ARGS__) : L3TestState, @class NSObject) 

#else

#define l3_suite(str, ...) \
	l3_cond(l3_count(__VA_ARGS__), interface L3TestState (l3_state_class(__VA_ARGS__)), class NSObject)

#endif


#pragma mark -
#pragma mark Test cases

#if L3_DEBUG

#define l3_set_up \
	class L3TestSuite, L3TestCase; \
	\
	static void l3_identifier(set_up_, __LINE__)(l3_type_of_state_class __strong test, L3TestSuite *suite, L3TestCase *testCase); \
	\
	__attribute__((constructor)) static void l3_identifier(set_up_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			l3_current_suite.setUpFunction = l3_identifier(set_up_, __LINE__); \
		} \
	} \
	\
	static void l3_identifier(set_up_, __LINE__)(l3_type_of_state_class __strong test, L3TestSuite *suite, L3TestCase *testCase)

#define l3_test(str) \
	class L3TestSuite, L3TestCase; \
	\
	static void l3_identifier(test_case_impl_, __LINE__)(l3_type_of_state_class __strong test, L3TestSuite *suite, L3TestCase *testCase); \
	static L3TestCase *l3_identifier(test_case_builder_, __LINE__)(); \
	\
	__attribute__((constructor)) static void l3_identifier(test_case_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			[l3_current_suite addTestCase:l3_identifier(test_case_builder_, __LINE__)(nil)]; \
		} \
	} \
	static L3TestCase *l3_identifier(test_case_builder_, __LINE__)() { \
		return [L3TestCase testCaseWithName:@"" str function:l3_identifier(test_case_impl_, __LINE__)]; \
	} \
	static void l3_identifier(test_case_impl_, __LINE__)(l3_type_of_state_class __strong test, L3TestSuite *suite, L3TestCase *testCase)

#else

#define l3_set_up \
	l3_test("")

#define l3_test(str) \
	class NSObject; \
	__attribute__((unused)) \
	static void l3_identifier(ignored_test_case_, __COUNTER__)(L3TestState *test, L3TestSuite *suite, L3TestCase *testCase)

#endif


#pragma mark -
#pragma mark Macro utilities

#define l3_domain						com_antitypical_lagrangian_
#define l3_identifier(sym, line)		l3_paste(l3_paste(l3_domain, sym), line)

#define l3_paste(a, b)					l3_paste_implementation(a, b)
#define l3_paste_implementation(a, b)	a##b

#define l3_string(x)					l3_string_implementation(x)
#define l3_string_implementation(x)		#x

#define l3_bool(x)						l3_bool_implementation(x)
#define l3_bool_implementation(x)		l3_paste(l3_bool_, x)
#define l3_bool_0						0
#define l3_bool_1						1
#define l3_bool_2						1
#define l3_bool_3						1
#define l3_bool_4						1
#define l3_bool_5						1
#define l3_bool_6						1
#define l3_bool_7						1
#define l3_bool_8						1
#define l3_bool_9						1

#define l3_cond(cond, then, else)		l3_cond_implementation(cond, then, else)
#define l3_cond_implementation(cond, then, else) \
	l3_paste(l3_cond_, l3_bool(cond))(then, else)
#define l3_cond_0(x, y)					y
#define l3_cond_1(x, y)					x

#define l3_count(...) \
	l3_count_implementation(_0, ## __VA_ARGS__, l3_reverse_ordinals())
#define l3_count_implementation(...) \
	l3_ordinals(__VA_ARGS__)
#define l3_ordinals( \
	 _0, \
	 _1, _2, _3, _4, _5, _6, _7, _8, _9,_10, \
	_11,_12,_13,_14,_15,_16,_17,_18,_19,_20, \
	_21,_22,_23,_24,_25,_26,_27,_28,_29,_30, \
	_31,_32,_33,_34,_35,_36,_37,_38,_39,_40, \
	_41,_42,_43,_44,_45,_46,_47,_48,_49,_50, \
	_51,_52,_53,_54,_55,_56,_57,_58,_59,_60, \
	_61,_62,_63,  N,...) N
#define l3_reverse_ordinals() \
	63, 62, 61, 60,                         \
	59, 58, 57, 56, 55, 54, 53, 52, 51, 50, \
	49, 48, 47, 46, 45, 44, 43, 42, 41, 40, \
	39, 38, 37, 36, 35, 34, 33, 32, 31, 30, \
	29, 28, 27, 26, 25, 24, 23, 22, 21, 20, \
	19, 18, 17, 16, 15, 14, 13, 12, 11, 10, \
	9,  8,  7,  6,  5,  4,  3,  2,  1,  0



#pragma mark -
#pragma mark State types

#define l3_type_of_state_class			l3_type_of_state_class_implementation(l3_state_class_variable)
#define l3_type_of_state_class_implementation(x) \
	__typeof__(x)
#define l3_state_class_variable			l3_paste(l3_domain, state_class_variable)
#define l3_state_class(identifier)		l3_paste(l3_domain, l3_paste(__VA_ARGS__, TestState))


#pragma mark -
#pragma mark Test state

#define l3_current_suite				l3_paste(l3_domain, current_suite)

#if L3_DEBUG

static L3TestSuite *l3_current_suite = nil;

#endif
