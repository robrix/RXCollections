//  RXTraversalArray.h
//  Created by Rob Rix on 2013-03-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

@interface RXTraversalArray : NSArray

+(instancetype)arrayWithTraversal:(id<RXTraversal>)traversal;
+(instancetype)arrayWithTraversal:(id<RXTraversal>)traversal count:(NSUInteger)count;

@end
