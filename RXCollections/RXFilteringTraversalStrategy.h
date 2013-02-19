//  RXFilteringTraversalStrategy.h
//  Created by Rob Rix on 2013-02-19.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerationTraversal.h>

@interface RXFilteringTraversalStrategy : NSObject <RXEnumerationTraversalStrategy>

+(instancetype)strategyWithBlock:(bool(^)(id))block;

@property (nonatomic, copy, readonly) bool(^block)(id);

@end
