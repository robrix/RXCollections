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

@dynamic cardinality;
@dynamic elements;

#pragma mark Construction

@l3_test("generates class names for a given cardinality") {
	l3_assert([RXTuple classNameWithCardinality:0], @"RX0Tuple");
}

+(NSString *)classNameWithCardinality:(NSUInteger)cardinality {
	return [NSString stringWithFormat:@"RX%luTuple", (unsigned long)cardinality];
}

+(Class)subclassWithCardinality:(NSUInteger)cardinality {
	const char *subclassName = [self classNameWithCardinality:cardinality].UTF8String;
	Class subclass = objc_getClass(subclassName);
	if (!subclass) {
		subclass = objc_allocateClassPair(self, subclassName, 0);
		
		const char *elementsVariableName = "_elements";
		Ivar elementsVariable = class_getInstanceVariable(subclass, elementsVariableName);
		class_addIvar(subclass, elementsVariableName, sizeof(id) * cardinality, log2(sizeof(id)), @encode(id[cardinality]));
		class_addMethod(subclass, @selector(elements), imp_implementationWithBlock(^(id self){ return object_getIvar(self, elementsVariable); }), (const char []){ *@encode(id[cardinality]), *@encode(id), *@encode(SEL) });
		
		class_addMethod(subclass, @selector(cardinality), imp_implementationWithBlock(^(id self){ return cardinality; }), (const char []){ *@encode(NSUInteger), *@encode(id), *@encode(SEL) });
		
		objc_registerClassPair(subclass);
	}
	return subclass;
}

+(instancetype)tupleWithArray:(NSArray *)array {
	return [[[self subclassWithCardinality:array.count] alloc] initWithArray:array];
}

-(instancetype)initWithArray:(NSArray *)array {
	NSParameterAssert(array != nil);
	NSParameterAssert(array.count == self.cardinality);
	
	if ((self = [super init])) {
		id __strong *elements = self.elements;
		for (id element in array) {
			*elements = element;
			elements++;
		}
	}
	return self;
}


#pragma mark Access

-(id)objectAtIndexedSubscript:(NSUInteger)subscript {
	NSParameterAssert(subscript < self.cardinality);
	
	return self.elements[subscript];
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	state->state = 1;
	state->itemsPtr = (__unsafe_unretained id *)(void *)self.elements;
	state->mutationsPtr = state->extra;
	return self.cardinality;
}

@end
