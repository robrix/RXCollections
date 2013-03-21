//  RXFold.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXPair.h"
#import "RXTraversalArray.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXFold");

@l3_test("produces a result by recursively enumerating the collection") {
	NSString *result = RXFold((@[@"Quantum", @"Boomerang", @"Physicist", @"Cognizant"]), @"", ^(NSString * memo, NSString * each) {
		return [memo stringByAppendingString:each];
	});
	l3_assert(result, @"QuantumBoomerangPhysicistCognizant");
}

id RXFold(id<NSFastEnumeration> enumeration, id initial, RXFoldBlock block) {
	for (id each in enumeration) {
		initial = block(initial, each);
	}
	return initial;
}


#pragma mark Constructors

@l3_suite("RXConstruct");

@l3_test("constructs arrays from traversals") {
	l3_assert(RXConstructArray(@[@1, @2, @3]), l3_is(@[@1, @2, @3]));
}

NSArray *RXConstructArray(id<RXTraversal> traversal) {
	return [RXTraversalArray arrayWithTraversal:traversal];
}

@l3_test("constructs sets from enumerations") {
	l3_assert(RXConstructSet(@[@1, @2, @3]), l3_is([NSSet setWithObjects:@1, @2, @3, nil]));
}

NSSet *RXConstructSet(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableSet set], ^(NSMutableSet *memo, id each) {
		[memo addObject:each];
		return memo;
	});
}

@l3_test("constructs dictionaries from enumerations of pairs") {
	l3_assert(RXConstructDictionary(@[[RXPair pairWithKey:@1 value:@1], [RXPair pairWithKey:@2 value:@4], [RXPair pairWithKey:@3 value:@9]]), l3_is(@{@1: @1, @2: @4, @3: @9}));
}

NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableDictionary new], ^(NSMutableDictionary *memo, id<RXKeyValuePair> each) {
		[memo setObject:each.value forKey:each.key];
		return memo;
	});
}

//bool RXTraversalCopyN(id<RXTraversal> traversal, __strong id buffer[], NSUInteger *capacity);
//bool RXTraversalCopyN(id<RXTraversal> traversal, __strong id buffer[], NSUInteger *capacity) {
//	NSCParameterAssert(traversal != nil);
//	NSCParameterAssert(buffer != NULL);
//	NSCParameterAssert(capacity != NULL);
//	NSCParameterAssert(*capacity > 0);
//	
//	bool wouldOverflow = NO;
//	NSUInteger index = 0;
//	for (id element in traversal) {
//		if (index >= *capacity) {
//			wouldOverflow = YES;
//			break;
//		}
//		buffer[index] = element;
//		index++;
//	}
//	return wouldOverflow;
//}
//
//__strong id *RXTraversalCopy(id<RXTraversal> traversal, __strong id buffer[], NSUInteger *capacity);
//__strong id *RXTraversalCopy(id<RXTraversal> traversal, __strong id buffer[], NSUInteger *capacity) {
//	NSCParameterAssert(traversal != nil);
//	NSCParameterAssert(buffer != NULL);
//	NSCParameterAssert(capacity != NULL);
//	
//	// intention: given a traversal, a buffer, and its capacity, return a buffer containing the objects in the traversal, using the passed-in buffer if it's large enough and using malloc/realloc otherwise, and return the actual count by reference
//	
//	NSUInteger count = [traversal respondsToSelector:@selector(count)]?
//		[(id<RXFiniteTraversal>)traversal count]
//	:	0;
//	
//	__strong id *objects = buffer;
//	if (count > *capacity) {
//		objects = (__strong id *)malloc(count * sizeof(id));
//	}
//	
//	for (id element in traversal) {
//		if (count > *capacity) {
//			
//		}
//		objects[count] = element;
//		
//		count++;
//	}
//	
//	*capacity = count;
//	
//	return objects;
//}
//
//@l3_test("constructs tuples") {
//	l3_assert(RXConstructTuple(@[@1, @2]), ([RXTuple tupleWithArray:@[@1, @2]]));
//}
//
//RXTuple *RXConstructTuple(id<RXTraversal> traversal) {
//	NSUInteger capacity = [traversal respondsToSelector:@selector(count)]?
//		[(id<RXFiniteTraversal>)traversal count]
//	:	16;
//	__strong id buffer[capacity];
//	__strong id *objects = RXTraversalCopy(traversal, buffer, &capacity);
//	
//	return [RXTuple tupleWithObjects:objects count:capacity];
//}
