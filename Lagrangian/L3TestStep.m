//  L3TestStep.m
//  Created by Rob Rix on 2012-11-17.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestStep.h"

@implementation L3TestStep

#pragma mark Constructors

+(instancetype)stepWithName:(NSString *)name function:(L3TestStepFunction)function {
	return [[self alloc] initWithName:name function:function];
}

-(instancetype)initWithName:(NSString *)name function:(L3TestStepFunction)function {
	NSParameterAssert(name != nil);
	NSParameterAssert(function != nil);
	if ((self = [super init])) {
		_name = name;
		_function = function;
	}
	return self;
}

@end
