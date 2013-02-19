//  RXMappingTraversalStrategy.h
//  Created by Rob Rix on 2013-02-19.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerationTraversal.h>

@interface RXMappingTraversalStrategy : NSObject <RXEnumerationTraversalStrategy>

+(instancetype)strategyWithBlock:(id(^)(id))block;

@property (nonatomic, copy, readonly) id(^block)(id);

@end
