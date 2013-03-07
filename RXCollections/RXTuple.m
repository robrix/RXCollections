//  RXTuple.m
//  Created by Rob Rix on 2013-03-06.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXTuple.h"
#import <objc/runtime.h>

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXTuple");

@interface RXTuple ()

@property (nonatomic, readonly) __strong id *elements;

@end

@implementation RXTuple

#pragma mark Construction

@l3_test("generates class names for a given cardinality") {
	l3_assert([RXTuple classNameWithCardinality:0], @"RX0Tuple");
}

+(NSString *)classNameWithCardinality:(NSUInteger)cardinality {
	return [NSString stringWithFormat:@"RX%luTuple", (unsigned long)cardinality];
}


@l3_test("generates subclasses for a given cardinality") {
	Class subclass = [RXTuple subclassWithCardinality:2];
	l3_assert(subclass, l3_not(Nil));
}

@l3_test("reuses extant subclasses for a given cardinality") {
	Class subclass = [RXTuple subclassWithCardinality:3];
	Class secondSubclass = [RXTuple subclassWithCardinality:3];
	l3_assert((uintptr_t)subclass, (uintptr_t)secondSubclass);
}

+(Class)subclassWithCardinality:(NSUInteger)cardinality {
	const char *subclassName = [self classNameWithCardinality:cardinality].UTF8String;
	Class subclass = objc_getClass(subclassName);
	if (!subclass) {
		subclass = objc_allocateClassPair(self, subclassName, 0);
		
		const char *elementsVariableName = "_elements";
		class_addIvar(subclass, elementsVariableName, sizeof(id[cardinality]), log2(sizeof(id *)), @encode(id[cardinality]));
		Ivar elementsVariable = class_getInstanceVariable(subclass, elementsVariableName);
		ptrdiff_t elementsOffset = ivar_getOffset(elementsVariable);
		
		Method elementsMethod = class_getInstanceMethod(subclass, @selector(elements));
		class_addMethod(subclass, @selector(elements), imp_implementationWithBlock(^(id self){ return ((__strong id *)(__bridge void *)self) + (elementsOffset / sizeof(id)); }), method_getTypeEncoding(elementsMethod));
		
		Method cardinalityMethod = class_getInstanceMethod(subclass, @selector(cardinality));
		class_addMethod(subclass, @selector(cardinality), imp_implementationWithBlock(^(id self){ return cardinality; }), method_getTypeEncoding(cardinalityMethod));
		
		objc_registerClassPair(subclass);
	}
	return subclass;
}


@l3_test("builds tuples with arrays") {
	RXTuple *tuple = [RXTuple tupleWithArray:@[@1, @2, @3]];
	l3_assert(tuple, l3_not(nil));
}

+(instancetype)tupleWithArray:(NSArray *)array {
	return [[[self subclassWithCardinality:array.count] alloc] initWithArray:array];
}

-(instancetype)initWithArray:(NSArray *)array {
	NSParameterAssert(array != nil);
	NSParameterAssert(array.count == self.cardinality);
	
	if ((self = [super init])) {
		for (NSUInteger index = 0; index < self.cardinality; index++) {
			self.elements[index] = array[index];
		}
	}
	return self;
}


#pragma mark Access

@l3_test("has a specific cardinality") {
	RXTuple *tuple = [RXTuple tupleWithArray:@[@M_PI, @M_PI]];
	l3_assert(tuple.cardinality, 2);
}

-(NSUInteger)cardinality {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

-(__strong id *)elements {
	[self doesNotRecognizeSelector:_cmd];
	return NULL;
}


@l3_test("retrieves items by index") {
	RXTuple *tuple = [RXTuple tupleWithArray:@[@0, @1, @2]];
	l3_assert(tuple[2], @2);
}

-(id)objectAtIndexedSubscript:(NSUInteger)subscript {
	NSParameterAssert(subscript < self.cardinality);
	
	return self.elements[subscript];
}


#pragma mark NSFastEnumeration

@l3_test("implements fast enumeration by returning an internal pointer") {
	RXTuple *tuple = [RXTuple tupleWithArray:@[@0, @1, @2]];
	NSFastEnumerationState state = {};
	__unsafe_unretained id objects[4];
	NSUInteger count = [tuple countByEnumeratingWithState:&state objects:objects count:sizeof objects / sizeof *objects];
	l3_assert(count, 3);
	l3_assert(state.itemsPtr[0], @0);
	l3_assert(state.itemsPtr[1], @1);
	l3_assert(state.itemsPtr[2], @2);
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	state->state = 1;
	state->itemsPtr = (__unsafe_unretained id *)(void *)self.elements;
	state->mutationsPtr = state->extra;
	return self.cardinality;
}

@end
