//  RXGeneratorTraversal.h
//  Created by Rob Rix on 2013-03-09.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

typedef id (^RXGenerator)();
typedef RXGenerator (^RXGeneratorProvider)();

@interface RXGeneratorTraversal : NSObject <NSFastEnumeration>

+(instancetype)traversalWithGeneratorProvider:(RXGeneratorProvider)provider;

@property (nonatomic, copy, readonly) RXGeneratorProvider provider;

@end
