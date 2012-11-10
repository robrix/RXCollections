//  Lagrangian.m
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "Lagrangian.h"

@l3_suite("Lagrangian tests", Lagrangian)
@property L3TestSuite *testSuite;
@end

@l3_suite("Hello");

//@l3_suite_state("Lagrangian tests 2");
//@end

//@l3_setUp {
//	
//}

@l3_test("test cases take a reference to their test suite") {
	assert(suite != nil);
}

@l3_test("test cases take a reference to their test case") {
	assert(testCase != nil);
}

@l3_test("test cases take a reference to their test state") {
	assert(test != nil);
}


//@l3tearDown {
//	
//}


//@l3precondition {
//	
//}

//@l3postcondition {
//	
//}

//@l3invariant {
//	
//}

//@l3benchmark {
//	
//}
