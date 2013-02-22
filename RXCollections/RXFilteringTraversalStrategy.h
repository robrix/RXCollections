//  RXFilteringTraversalStrategy.h
//  Created by Rob Rix on 2013-02-19.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerationTraversal.h>
#import <RXCollections/RXFilter.h>

@interface RXFilteringTraversalStrategy : NSObject <RXEnumerationTraversalStrategy>

+(instancetype)strategyWithBlock:(RXFilterBlock)block;

@property (nonatomic, copy, readonly) RXFilterBlock block;

@end
