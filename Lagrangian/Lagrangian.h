//  Lagrangian.h
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Configuration.h>
#import <Lagrangian/L3SourceReference.h>
#import <Lagrangian/L3Assertions.h>
#import <Lagrangian/L3PreprocessorUtilities.h>
#import <Lagrangian/L3TestCase.h>
#import <Lagrangian/L3TestRunner.h>
#import <Lagrangian/L3TestState.h>
#import <Lagrangian/L3TestStep.h>
#import <Lagrangian/L3TestSuite.h>
#import <Lagrangian/L3Mock.h>

#import <Lagrangian/RXCount.h>

#pragma mark Test suites

/*
 l3_suite_interface is intended to be used like so:
 
 @l3_suite_interface(identifier, "Suite name")
 @property id propertyDeclarations;
 …
 @end
 
 or
 
 @l3_suite_interface(identifier)
 @property id propertyDeclarations;
 …
 @end
 
 (which uses the identifier for the suite name as well) to declare the state that your tests require. In this usage, a subclass of L3TestState is defined, and your test cases are passed instances of it; this means that they can use its properties with strong typing:
 
 @l3_test("tests defined in a l3_suite_interface suite can access its properties directly") {
	test.propertyDeclarations = @"function correctly";
 }
 
 You will also need to define the implementation, whether or not you need to implement any methods within it:
 
 @l3_suite_implementation(identifier)
 @end
 
 Remember to use the same identifier as you passed to l3_suite_interface; it is convenient and recommended to use the name of the class you are testing.
 
 
 Alternatively, you can use l3_suite to define a suite without declaring any state.
 
 @l3_suite("Suite name");
 
 Note the semicolon. In this usage, it declares the suite, but does not declare any state; your tests are passed standard L3TestState instances.
 */

#define l3_suite(str) \
	class NSObject; \
	\
	l3_suite_setup(str)

#define l3_suite_interface(identifier, ...) \
	class NSObject; \
	\
	l3_cond(rx_count(__VA_ARGS__), l3_suite_interface_implementation(identifier, __VA_ARGS__), l3_suite_interface_implementation(identifier, #identifier))\


#if L3_INCLUDE_TESTS // debug build

#define l3_suite_builder_function \
	l3_identifier(test_suite_builder_, __LINE__)

#define l3_suite_builder(str, ...) \
	static L3TestSuite *l3_suite_builder_function(); \
	static L3TestSuite *l3_suite_builder_function() { \
		static L3TestSuite *suite = nil; \
		static dispatch_once_t onceToken; \
		dispatch_once(&onceToken, ^{ \
			suite = [L3TestSuite testSuiteWithName:@"" str file:@"" __FILE__ line:__LINE__]; \
			l3_cond(rx_count(__VA_ARGS__), suite.stateClass = NSClassFromString(@"" l3_string(l3_state_class(__VA_ARGS__))), {});\
			if (L3MachOImagePathForAddress != NULL) \
				suite.imagePath = L3MachOImagePathForAddress(l3_suite_builder_function); \
		}); \
		return suite; \
	}

#define l3_suite_loader() \
	__attribute__((constructor)) static void l3_identifier(test_suite_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			L3TestSuite *suite = l3_identifier(test_suite_builder_, __LINE__)(); \
			[[L3TestSuite defaultSuite] addTest:suite]; \
			l3_current_suite = suite; \
		} \
	}

#define l3_suite_setup(str, ...) \
	l3_suite_builder(str, __VA_ARGS__) \
	l3_suite_loader() \
	\
	@class l3_cond(rx_count(__VA_ARGS__), l3_state_class(__VA_ARGS__), L3TestState); \
	static l3_cond(rx_count(__VA_ARGS__), l3_state_class(__VA_ARGS__), L3TestState) *l3_state_class_variable; \

#define l3_suite_interface_implementation(identifier, str) \
	l3_suite_setup(str, identifier) \
	\
	@interface l3_state_class(identifier) : L3TestState

#define l3_suite_implementation(identifier) \
	implementation l3_state_class(identifier)


#else // release build

#define l3_ignored_class(identifier) \
	rx_paste(l3_state_class(identifier), _ignored_class)

#define l3_suite_setup(str) \
	@class NSObject

#define l3_suite_interface_implementation(identifier, str) \
	@class l3_ignored_class(identifier); \
	@interface l3_ignored_class(identifier) : L3TestState \
	@end \
	@implementation l3_ignored_class(identifier) \
	@end \
	@interface l3_ignored_class(identifier) (l3_state_class(identifier)) \
	@end \
	@interface L3TestState (rx_paste(l3_state_class(identifier), _ignored))

#define l3_suite_implementation(identifier) \
	class NSObject; \
	@implementation l3_ignored_class(identifier) (l3_state_class(identifier))

#endif


#pragma mark Test cases

#if L3_INCLUDE_TESTS // debug build

#define l3_step(str) \
	class L3TestStep; \
	\
	static void l3_identifier(test_step_impl_, __LINE__)(l3_type_of_state_class __strong test, L3TestCase *self, L3TestStep *step); \
	\
	__attribute__((constructor)) static void l3_identifier(test_step_loader, __COUNTER__)() { \
		@autoreleasepool { \
			[l3_current_suite ?: [L3TestSuite defaultSuite] addStep:[L3TestStep stepWithName:@"" str function:l3_identifier(test_step_impl_, __LINE__)]]; \
		} \
	} \
	\
	static void l3_identifier(test_step_impl_, __LINE__)(l3_type_of_state_class __strong test, L3TestCase *self, L3TestStep *step)

#define l3_set_up \
	l3_step("set up")

#define l3_tear_down \
	l3_step("tear down")

#define l3_test(str) \
	class L3TestSuite, L3TestCase; \
	\
	static void l3_identifier(testself_impl_, __LINE__)(l3_type_of_state_class __strong test, L3TestCase *testCase); \
	\
	__attribute__((constructor)) static void l3_identifier(testself_loader_, __COUNTER__)() { \
		@autoreleasepool { \
			[l3_current_suite ?: [L3TestSuite defaultSuite] addTest:[L3TestCase testCaseWithName:@"" str file:@"" __FILE__ line:__LINE__ function:l3_identifier(testself_impl_, __LINE__)]]; \
		} \
	} \
	\
	static void l3_identifier(testself_impl_, __LINE__)(l3_type_of_state_class __strong test, L3TestCase *self)

#else

#define l3_set_up \
	l3_test("")

#define l3_tear_down \
	l3_test("")

#define l3_step(str) \
	l3_test("")

#define l3_test(str) \
	class NSObject; \
	__attribute__((unused)) \
	static void l3_identifier(ignored_testself_, __COUNTER__)(L3TestState *test, L3TestCase *self, L3TestStep *step)

#endif


#define l3_perform_step(str) \
	[self performStep:test.suite.steps[@"" str] withState:test]


#pragma mark State types

#define l3_type_of_state_class			l3_type_of_state_class_implementation(l3_state_class_variable)
#define l3_type_of_state_class_implementation(x) \
	__typeof__(x)
#define l3_state_class_variable			rx_paste(l3_domain, state_class_variable)
#define l3_state_class(identifier)		rx_paste(l3_domain, rx_paste(identifier, TestState))


#pragma mark Test state

#define l3_current_suite				rx_paste(l3_domain, current_suite)


#if L3_INCLUDE_TESTS

static L3TestSuite *l3_current_suite = nil;

#endif
