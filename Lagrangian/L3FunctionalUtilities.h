//  L3FunctionalUtilities.h
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

#pragma mark Let

typedef id(^L3UnaryLetBlock)(id);
typedef id(^L3BinaryLetBlock)(id, id);
typedef id(^L3TernaryLetBlock)(id, id, id);

#define l3_unary(type)				(L3UnaryLetBlock)^id(type)
#define l3_binary(typeA, typeB)		(L3BinaryLetBlock)^id(typeA, typeB)

__attribute__((overloadable)) static inline id l3_let(id x, L3UnaryLetBlock block) {
	return block(x);
}

__attribute__((overloadable)) static inline id l3_let(id x, id y, L3BinaryLetBlock block) {
	return block(x, y);
}

__attribute__((overloadable)) static inline id l3_let(id x, id y, id z, L3TernaryLetBlock block) {
	return block(x, y, z);
}


#pragma mark Fold

typedef id (^L3FoldBlock)(id accumulation, id element);
id L3Fold(id<NSFastEnumeration> collection, id initialAccumulation, L3FoldBlock block);


#pragma mark Map

typedef id(^L3MapBlock)(id element);

// returns a new collection of the same type as the first argument; typed as id because ObjC can’t convey that information in its type system
id L3Map(id<NSFastEnumeration> collection, L3MapBlock block);
