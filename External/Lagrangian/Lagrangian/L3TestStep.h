//  L3TestStep.h
//  Created by Rob Rix on 2012-11-17.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Lagrangian/L3Types.h>

@interface L3TestStep : NSObject

+(instancetype)stepWithName:(NSString *)name function:(L3TestStepFunction)function;

@property (copy, nonatomic, readonly) NSString *name;

@property (assign, nonatomic, readonly) L3TestStepFunction function;

@end
