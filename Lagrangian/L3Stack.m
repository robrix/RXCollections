//  L3Stack.m
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Stack.h"
#import "Lagrangian.h"

@interface L3Stack ()

@property (nonatomic, readonly) NSMutableArray *mutableObjects;

@end

@implementation L3Stack

@l3_suite("Stacks");

@l3_set_up {
	test[@"stack"] = [L3Stack new];
}

#pragma mark Constructors

@l3_test("are initialized with an empty array of objects") {
	l3_assert([test[@"stack"] mutableObjects], l3_is(@[]));
}

-(instancetype)init {
	if ((self = [super init])) {
		_mutableObjects = [NSMutableArray new];
	}
	return self;
}


#pragma mark Public methods

@l3_test("push objects by adding them to the end of their arrays") {
	[test[@"stack"] pushObject:_case.name];
	l3_assert([test[@"stack"] mutableObjects], l3_is(@[_case.name]));
}

-(void)pushObject:(id)object {
	[self.mutableObjects addObject:object];
}

@l3_test("pop objects by removing them from the end of their arrays and returning them") {
	[test[@"stack"] pushObject:_case.name];
	l3_assert([test[@"stack"] popObject], l3_is(_case.name));
	l3_assert([test[@"stack"] mutableObjects], @[]);
}

-(id)popObject {
	id object = self.topObject;
	[self.mutableObjects removeLastObject];
	return object;
}


@l3_test("use the last object in their arrays as the top object") {
	[test[@"stack"] pushObject:_case.name];
	l3_assert([test[@"stack"] topObject], _case.name);
}

-(id)topObject {
	return self.mutableObjects.lastObject;
}


@l3_test("return their contents") {
	[test[@"stack"] pushObject:_case.name];
	[test[@"stack"] pushObject:_case.name];
	l3_assert([test[@"stack"] objects], l3_equals(@[_case.name, _case.name]));
}

-(NSArray *)objects {
	return self.mutableObjects;
}

@end
