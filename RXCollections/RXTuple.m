//  RXTuple.m
//  Created by Rob Rix on 2013-03-06.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXTuple.h"
#import <objc/runtime.h>

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXTuple");

@interface RXTuple ()

@property (nonatomic, readonly) __strong id *elements;

@end

@implementation RXTuple

#pragma mark Construction

@l3_test("generates class names for a given count") {
	l3_assert([RXTuple classNameWithCount:0], @"RX0Tuple");
}

+(NSString *)classNameWithCount:(NSUInteger)count {
	return [NSString stringWithFormat:@"RX%luTuple", (unsigned long)count];
}


@l3_test("generates subclasses for a given count") {
	Class subclass = [RXTuple subclassWithCount:2];
	l3_assert(subclass, l3_not(Nil));
}

@l3_test("reuses extant subclasses for a given count") {
	Class subclass = [RXTuple subclassWithCount:3];
	Class secondSubclass = [RXTuple subclassWithCount:3];
	l3_assert((uintptr_t)subclass, (uintptr_t)secondSubclass);
}

+(Class)subclassWithCount:(NSUInteger)count {
	const char *subclassName = [self classNameWithCount:count].UTF8String;
	Class subclass = objc_getClass(subclassName);
	if (!subclass) {
		subclass = objc_allocateClassPair(self, subclassName, 0);
		
		const char *elementsVariableName = "_elements";
		class_addIvar(subclass, elementsVariableName, sizeof(id[count]), log2(sizeof(id *)), @encode(id[count]));
		Ivar elementsVariable = class_getInstanceVariable(subclass, elementsVariableName);
		ptrdiff_t elementsOffset = ivar_getOffset(elementsVariable);
		
		Method elementsMethod = class_getInstanceMethod(subclass, @selector(elements));
		class_addMethod(subclass, @selector(elements), imp_implementationWithBlock(^(id self){ return ((__strong id *)(__bridge void *)self) + (elementsOffset / sizeof(id)); }), method_getTypeEncoding(elementsMethod));
		
		Method countMethod = class_getInstanceMethod(subclass, @selector(count));
		class_addMethod(subclass, @selector(count), imp_implementationWithBlock(^(id self){ return count; }), method_getTypeEncoding(countMethod));
		
		objc_registerClassPair(subclass);
	}
	return subclass;
}


@l3_test("builds tuples with C arrays") {
	id const objects[] = {@1, @1, @2};
	RXTuple *tuple = [RXTuple tupleWithObjects:objects count:sizeof objects / sizeof *objects];
	l3_assert(tuple, ([RXTuple tupleWithArray:@[@1, @1, @2]]));
}

+(instancetype)tupleWithObjects:(id const [])objects count:(NSUInteger)count {
	return [[(id)[self subclassWithCount:count] alloc] initWithObjects:objects count:count];
}

-(instancetype)initWithObjects:(id const [])objects count:(NSUInteger)count {
	NSParameterAssert(objects != NULL);
	NSParameterAssert(count == self.count);
	
	if ((self = [super init])) {
		for (NSUInteger index = 0; index < self.count; index++) {
			self.elements[index] = objects[index];
		}
	}
	return self;
}


@l3_test("builds tuples with arrays") {
	RXTuple *tuple = [RXTuple tupleWithArray:@[@1, @2, @3]];
	l3_assert(tuple, l3_not(nil));
}

+(instancetype)tupleWithArray:(NSArray *)array {
	return [[(id)[self subclassWithCount:array.count] alloc] initWithArray:array];
}

-(instancetype)initWithArray:(NSArray *)array {
	NSParameterAssert(array != nil);
	NSParameterAssert(array.count == self.count);
	
	if ((self = [super init])) {
		for (NSUInteger index = 0; index < self.count; index++) {
			self.elements[index] = array[index];
		}
	}
	return self;
}

/*
 Since the tuple class and its elements ivar is created at runtime, ARC does not have the information necessary to release the contained objects, even if it had the opportunity to generate the correct -dealloc method for us.
 Assigning nil to each element ensures that ARC can release its previous (strongly-held) reference (if any), per http://clang.llvm.org/docs/AutomaticReferenceCounting.html#conversion-of-pointers-to-ownership-qualified-types
 h/t to @rustle for catching this and suggesting this explanatory comment.
*/
-(void)dealloc {
	__strong id *elements = self.elements;
	for (NSUInteger i = 0; i < self.count; i++) {
		elements[i] = nil;
	}
}


#pragma mark Access

@l3_test("can return its contents as an array") {
	l3_assert(([[RXTuple tupleWithArray:@[@1, @2]] allObjects]), (@[@1, @2]));
}

-(NSArray *)allObjects {
	return [NSArray arrayWithObjects:self.elements count:self.count];
}


@l3_test("has a specific count") {
	RXTuple *tuple = [RXTuple tupleWithArray:@[@M_PI, @M_PI]];
	l3_assert(tuple.count, 2);
}

-(NSUInteger)count {
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
	NSParameterAssert(subscript < self.count);
	
	return self.elements[subscript];
}


#pragma mark NSObject

@l3_test("describes itself parenthesized and comma-separated") {
	RXTuple *tuple = [RXTuple tupleWithArray:@[@1, @2, @3]];
	l3_assert([tuple description], @"(1, 2, 3)");
}

-(NSString *)description {
	NSMutableString *description = RXFold(self, [@"(" mutableCopy], ^(NSMutableString *memo, id element, bool *stop) {
		if (memo.length > 1)
			[memo appendString:@", "];
		[memo appendString:[element description] ?: @"(null)"];
		return memo;
	});
	[description appendString:@")"];
	return description;
}


@l3_test("includes its class name and address in its debugging description") {
	RXTuple *tuple = [RXTuple tupleWithArray:@[]];
	l3_assert([[tuple debugDescription] hasPrefix:@"<RX0Tuple: 0x"], YES);
	l3_assert([[tuple debugDescription] hasSuffix:@"> ()"], YES);
}

-(NSString *)debugDescription {
	return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, self.description];
}


@l3_test("equality is defined piecewise") {
	RXTuple *left = [RXTuple tupleWithArray:@[@1, @2, @3]];
	RXTuple *right = [RXTuple tupleWithArray:@[@1, @2, @3]];
	l3_assert([left isEqualToTuple:right], YES);
}

-(bool)isEqualToTuple:(RXTuple *)tuple {
	bool isEqual =
		[tuple isKindOfClass:self.class]
	&&	tuple.count == self.count;
	
	for (NSUInteger index = 0; index < self.count; index++) {
		isEqual &= [tuple[index] isEqual:self[index]];
		if (!isEqual)
			break;
	}
	
	return isEqual;
}

-(BOOL)isEqual:(id)object {
	return [self isEqualToTuple:object];
}


@l3_test("hashes 0-tuples to 0") {
	l3_assert([RXTuple tupleWithArray:@[]].hash, 0);
}

@l3_test("hashes tuples with their elements' shifted hashes plus their count") {
	RXTuple *unary = [RXTuple tupleWithArray:@[@""]];
	RXTuple *tuple = [RXTuple tupleWithArray:@[unary, unary, unary]];
#if __LP64__
	NSUInteger expected = ((1ul << 42ul) | (1ul << 21ul) | 1ul) + 3;
#else
	NSUInteger expected = ((1ul << 20ul) | (1ul << 10ul) | 1ul) + 3;
#endif
	l3_assert(tuple.hash, expected);
}

-(NSUInteger)hash {
	const NSUInteger kCount = self.count;
	NSUInteger hash = 0;
	if (kCount) {
		const NSUInteger kWidth = sizeof(NSUInteger) * 8; // # of bits in a hash
		const NSUInteger kShift = kWidth / kCount;
		const NSUInteger kModulus = 1 << (kShift - 1);
		
		for (NSUInteger index = 0; index < kCount; index++) {
			id<NSObject> element = self[index];
			hash |= (element.hash % kModulus) << (kShift * index);
		}
	}
	return hash + kCount;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}


#pragma mark RXTraversable

-(id<RXTraversal>)traversal {
	return RXTraversalWithObjects(self, self.elements, self.count);
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	NSUInteger count = 0;
	if (!state->state) {
		count = state->state = self.count;
		state->itemsPtr = (__unsafe_unretained id *)(void *)self.elements;
		state->mutationsPtr = state->extra;
	}
	return count;
}

@end
