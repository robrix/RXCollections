//  L3Test.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3TestContext.h"

@protocol L3EventAlgebra;

@protocol L3Test <NSObject>

@property (copy, nonatomic, readonly) NSString *name;

@property (nonatomic, readonly, getter = isComposite) bool composite;

-(void)runInContext:(id<L3TestContext>)context eventAlgebra:(id<L3EventAlgebra>)eventAlgebra;

@end
