//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMap.h"
#import "RXQueue.h"
#import "RXTuple.h"
#import "RXTree.h"
#import <Lagrangian/Lagrangian.h>

id<RXEnumerator> RXTreeDepthFirstEnumerator(id<RXEnumerable> tree) {
	return RXMap(tree.enumeration, ^(id<RXEnumerable> each) {
		return RXTreeDepthFirstEnumerator(each);
	});
}
