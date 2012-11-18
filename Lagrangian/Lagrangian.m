//  Lagrangian.m
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "Lagrangian.h"

@l3_suite("Lagrangian");


@l3_test("set up functions are used to define state to be available during each test") {
	l3_assert(test[@"case"], l3_equalTo(_case));
}

@l3_set_up {
	test[@"case"] = _case;
}


@l3_test("test cases take a reference to their test case") {
	l3_assert(_case, l3_not(nil));
}

@l3_test("test cases take a reference to their test state") {
	l3_assert(test, l3_not(nil));
}


@l3_test("tests have a reference to their suite via their state") {
	l3_assert(test.suite, l3_not(nil));
	l3_assert(test.suite, l3_isKindOfClass([L3TestSuite class]));
	l3_assert(test.suite.name, l3_equals(@"Lagrangian"));
}


@l3_step("Create a step") {
	test[@"step"] = step;
}

@l3_test("steps are not run automatically") {
	l3_assert(test[@"step"], l3_equals(nil));
}

@l3_test("steps are reified and collected in the suite") {
	l3_assert(test.suite.steps[@"Create a step"], l3_not(nil));
}

@l3_test("steps can be performed individually") {
	
}

@l3_test("steps can perform other steps") {
	
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
