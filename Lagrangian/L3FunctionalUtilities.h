//  L3FunctionalUtilities.h
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

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
