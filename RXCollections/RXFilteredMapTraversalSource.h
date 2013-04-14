//  RXFilteredMapTraversalSource.h
//  Created by Rob Rix on 2013-04-14.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXFilter.h>
#import <RXCollections/RXMap.h>
#import <RXCollections/RXTraversal.h>

@interface RXFilteredMapTraversalSource : NSObject <RXTraversalSource>

+(instancetype)sourceWithTraversal:(id<RXTraversal>)traversal filter:(RXFilterBlock)filter map:(RXMapBlock)map;

@property (nonatomic, strong, readonly) id<RXTraversal> traversal;
@property (nonatomic, copy, readonly) RXFilterBlock filter;
@property (nonatomic, copy, readonly) RXMapBlock map;

@end
