//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXTuple.h"
#import "RXTree.h"
#import <Lagrangian/Lagrangian.h>

static inline RXCompositeTraversalSource RXTreeDepthFirstNodeTraversalSource(id<RXTraversal> nodes) {
	return ^bool(id<RXCompositeTraversal> traversal) {
		[traversal addTraversal:RXTreeDepthFirstTraversal([nodes nextObject])];
		return nodes.isExhausted;
	};
}

l3_addTestSubjectTypeWithFunction(RXTreeDepthFirstTraversal)

l3_test(&RXTreeDepthFirstTraversal, ^{
	id tree = [L3Mock mockNamed:@"RXTreeBranch" initializer:^(id<L3MockBuilder> builder) {
		id leaf = [L3Mock mockNamed:@"RXTreeLeaf" initializer:^(id<L3MockBuilder> builder) {
			[builder addMethodWithSelector:@selector(nodeTraversal) types:L3TypeSignature(id<RXTraversal>, id, SEL) block:^id<RXTraversal> {
				return nil;
			}];
		}];
		id<RXTraversal> branch = [RXTuple tupleWithArray:@[leaf]].traversal;
		[builder addMethodWithSelector:@selector(nodeTraversal) types:L3TypeSignature(id<RXTraversal>, id, SEL) block:^id<RXTraversal> {
			return branch;
		}];
	}];
	id<RXTraversal> traversal = RXTreeDepthFirstTraversal(tree);
	l3_expect([traversal nextObject]).to.equal(tree);
})

id<RXTraversal> RXTreeDepthFirstTraversal(id<RXTreeNode> tree) {
	id<RXTraversal> nodeTraversal = [tree nodeTraversal];
	return RXCompositeTraversalWithSource(^bool(id<RXCompositeTraversal> traversal) {
		[traversal addObject:tree];
		traversal.source = RXTreeDepthFirstNodeTraversalSource(nodeTraversal);
		return nodeTraversal.isExhausted;
	});
}
