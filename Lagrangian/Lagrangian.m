//  Lagrangian.m
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "Lagrangian.h"

@l3_suite("Lagrangian tests");

@l3_test("set up functions are used to define state to be available during each test") {
	assert(test[@"suite"] == suite);
}

@l3_set_up {
	test[@"suite"] = suite;
}


@l3_test("test cases take a reference to their test suite") {
	assert(suite != nil);
}

@l3_test("test cases take a reference to their test case") {
	assert(testCase != nil);
}

@l3_test("test cases take a reference to their test state") {
	assert(test != nil);
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
