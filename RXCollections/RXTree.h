//  RXTree.h
//  Created by Rob Rix on 2013-05-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

@protocol RXTreeNode <NSObject>

-(id<RXTraversal>)nodeTraversal;

@end

extern id<RXTraversal> RXTreeDepthFirstTraversal(id<RXTreeNode> tree);
