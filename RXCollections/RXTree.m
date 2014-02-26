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

id<RXTraversal> RXTreeDepthFirstTraversal(id<RXTreeNode> tree) {
	id<RXTraversal> nodeTraversal = [tree nodeTraversal];
	return RXCompositeTraversalWithSource(^bool(id<RXCompositeTraversal> traversal) {
		[traversal addObject:tree];
		traversal.source = RXTreeDepthFirstNodeTraversalSource(nodeTraversal);
		return nodeTraversal.isExhausted;
	});
}
