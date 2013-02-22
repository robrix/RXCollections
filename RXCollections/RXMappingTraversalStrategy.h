//  RXMappingTraversalStrategy.h
//  Created by Rob Rix on 2013-02-19.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerationTraversal.h>
#import <RXCollections/RXMap.h>

@interface RXMappingTraversalStrategy : NSObject <RXEnumerationTraversalStrategy>

+(instancetype)strategyWithBlock:(RXMapBlock)block;

@property (nonatomic, copy, readonly) RXMapBlock block;

@end
