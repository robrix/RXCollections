//  RXNilArray.m
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXAllocation.h"
#import "RXNilArray.h"
#import "RXSingleton.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXNilArray");

@implementation RXNilArray

+(instancetype)allocWithZone:(NSZone *)zone {
	return RXSingleton(self, ^{ return [self allocateWithExtraSize:0]; });
}


@l3_test("can contain non-nil entries") {
	NSArray *array = [[RXNilArray alloc] initWithObjects:(const id[]){ test } count:1];
	l3_assert(array[0], test);
}

@l3_test("can contain nil entries") {
	NSArray *array = [[RXNilArray alloc] initWithObjects:(const id [1]){ nil } count:1];
	l3_assert(array[0], nil);
}

-(instancetype)initWithObjects:(const id [])objects count:(NSUInteger)count {
	NSParameterAssert(objects != NULL);
	if ((self = [[self.class allocateWithExtraSize:sizeof(*objects) * count] init])) {
		_count = count;
		id __strong *contents = (id __strong *)self.extraSpace;
		for (NSUInteger i = 0; i < count; i++) {
			contents[i] = objects[i];
		}
	}
	return self;
}

/*
 Since this the extra space associated with instances is not managed by ARC at compile-time, it does not have the information necessary to release it. Therefore, we assign nil to each element to allow ARC to manage lifetimes explicitly, per http://clang.llvm.org/docs/AutomaticReferenceCounting.html#conversion-of-pointers-to-ownership-qualified-types
 */
-(void)dealloc {
	id __strong *contents = (id __strong *)self.extraSpace;
	for (NSUInteger i = 0; i < _count; i++) {
		contents[i] = nil;
	}
}


#pragma mark NSArray

-(id)objectAtIndex:(NSUInteger)index {
	NSParameterAssert(index < _count);
	
	return ((id __strong *)self.extraSpace)[index];
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}

@end
