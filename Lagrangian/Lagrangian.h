//  Lagrangian.h
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Assertions.h"
#import "L3PreprocessorUtilities.h"
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

/*
 l3_suite is intended to be used like so:
 
 @l3_suite("Suite name", identifier)
 @property id propertyDeclarations;
 …
 @end
 
 to declare the state that your tests require.
 
 You can also use it like this:
 
 @l3_suite("Suite name");
 
 Note the semicolon. In this usage, it declares the suite, but does not declare any state; your tests are passed standard L3TestState instances.
 */

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

#define l3_suite_implementation(identifier) \
	implementation l3_state_class(identifier)

#else

#define l3_suite(str, ...) \
	l3_cond(l3_count(__VA_ARGS__), interface L3TestState (l3_state_class(__VA_ARGS__)), class NSObject)

#define l3_suite_implementation(identifier) \
	implementation L3TestState (l3_state_class(identifier))

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
#pragma mark State types

#define l3_type_of_state_class			l3_type_of_state_class_implementation(l3_state_class_variable)
#define l3_type_of_state_class_implementation(x) \
	__typeof__(x)
#define l3_state_class_variable			l3_paste(l3_domain, state_class_variable)
#define l3_state_class(identifier)		l3_paste(l3_domain, l3_paste(identifier, TestState))


#pragma mark -
#pragma mark Test state

#define l3_current_suite				l3_paste(l3_domain, current_suite)

#if L3_DEBUG

static L3TestSuite *l3_current_suite = nil;

#endif
