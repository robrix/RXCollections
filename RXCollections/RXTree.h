//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

@protocol RXTreeNode <NSObject>

-(id<RXTraversal>)nodeTraversal;

@end

extern id<RXTraversal> RXTreeDepthFirstTraversal(id<RXTreeNode> tree);
