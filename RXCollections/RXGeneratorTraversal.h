//  RXGeneratorTraversal.h
//  Created by Rob Rix on 2013-03-09.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

typedef id (^RXGenerator)();

@interface RXGeneratorTraversal : NSObject <NSFastEnumeration>

+(instancetype)traversalWithGenerator:(RXGenerator)generator;

@property (nonatomic, copy, readonly) RXGenerator generator;

@end
