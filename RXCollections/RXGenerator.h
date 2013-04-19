//  RXGenerator.h
//  Created by Rob Rix on 2013-03-09.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

@protocol RXGenerator <NSObject>

@property (nonatomic, copy) id<NSObject, NSCopying> context;

-(void)complete;

@end

typedef id (^RXGeneratorBlock)(id<RXGenerator> generator);

id<RXTraversal> RXGenerator(id<NSObject, NSCopying> context, RXGeneratorBlock block);
/**
 id<RXTraversal> RXGenerator(id<NSObject, NSCopying> context, RXGeneratorBlock block)
 
 RXGenerator() takes a context object (which can be nil) and a generator block, and returns a traversal which produces objects using that block. Blocks are free to use the context pointer or data closed over from the scope they are created within at their option.
 */