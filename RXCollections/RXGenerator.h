//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

@protocol RXGenerator <NSObject, RXTraversable>

@property (nonatomic, copy) id<NSObject, NSCopying> context;

-(void)complete;

@end

typedef id (^RXGeneratorBlock)(id<RXGenerator> generator);


/**
 RXGenerator() takes a context object (which can be nil) and a generator block, and returns a traversal which produces objects using that block. Blocks are free to use the context pointer or data closed over from the scope they are created within at their option.
 */
extern id<RXGenerator> RXGenerator(id<NSObject, NSCopying> context, RXGeneratorBlock block);
