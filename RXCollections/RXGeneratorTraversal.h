//  RXGeneratorTraversal.h
//  Created by Rob Rix on 2013-03-09.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

typedef id (^RXGeneratorBlock)(id __autoreleasing *context, bool *stop);

@interface RXGeneratorTraversal : NSObject <NSFastEnumeration>

+(instancetype)generatorWithBlock:(RXGeneratorBlock)block;
+(instancetype)generatorWithContext:(id<NSCopying>)context block:(RXGeneratorBlock)block;

@property (nonatomic, copy, readonly) id<NSCopying> context;
@property (nonatomic, copy, readonly) RXGeneratorBlock block;

@end
