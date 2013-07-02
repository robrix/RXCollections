//  RXTree.m
//  Created by Rob Rix on 2013-05-29.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXTuple.h"
#import "RXTree.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXTree");

@l3_set_up {
	test[@"tree"] = [L3Mock mockNamed:@"RXTreeBranch" initializer:^(id<L3Mock> mock) {
		id leaf = [L3Mock mockNamed:@"RXTreeLeaf" initializer:^(id<L3Mock> mock) {
			[mock addMethodWithSelector:@selector(nodeTraversal) types:L3TypeSignature(id<RXTraversal>, id, SEL) block:^id<RXTraversal> {
				return nil;
			}];
		}];
		id<RXTraversal> branch = [RXTuple tupleWithArray:@[leaf]].traversal;
		[mock addMethodWithSelector:@selector(nodeTraversal) types:L3TypeSignature(id<RXTraversal>, id, SEL) block:^id<RXTraversal> {
			return branch;
		}];
	}];
}

static inline RXCompositeTraversalSource RXTreeDepthFirstNodeTraversalSource(id<RXTraversal> nodes) {
	return ^bool(id<RXCompositeTraversal> traversal) {
		[traversal addTraversal:RXTreeDepthFirstTraversal([nodes nextObject])];
		return nodes.isExhausted;
	};
}

@l3_test("adds itself to its depth first traversal") {
	id<RXTraversal> traversal = RXTreeDepthFirstTraversal(test[@"tree"]);
	l3_assert([traversal nextObject], test[@"tree"]);
}

id<RXTraversal> RXTreeDepthFirstTraversal(id<RXTreeNode> tree) {
	id<RXTraversal> nodeTraversal = [tree nodeTraversal];
	return RXCompositeTraversalWithSource(^bool(id<RXCompositeTraversal> traversal) {
		[traversal addObject:tree];
		traversal.source = RXTreeDepthFirstNodeTraversalSource(nodeTraversal);
		return nodeTraversal.isExhausted;
	});
}
