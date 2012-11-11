//  Lagrangian.m
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "Lagrangian.h"

@l3_suite("Lagrangian tests");

@l3_test("set up functions are used to define state to be available during each test") {
	l3_assert(test[@"suite"], l3_equalTo(suite));
}

@l3_set_up {
	test[@"suite"] = suite;
}


@l3_test("test cases take a reference to their test suite") {
	l3_assert(suite, l3_notNil());
}

@l3_test("test cases take a reference to their test case") {
	l3_assert(testCase, l3_notNil());
}

@l3_test("test cases take a reference to their test state") {
	l3_assert(test, l3_notNil());
}


//@l3_tear_down {
//	
//}


//@l3_precondition {
//	
//}

//@l3_postcondition {
//	
//}

//@l3_invariant {
//	
//}

//@l3_benchmark {
//	
//}
