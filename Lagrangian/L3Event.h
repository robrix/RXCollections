//  L3Event.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventAlgebra.h"

@interface L3Event : NSObject

-(instancetype)initWithDate:(NSDate *)date;

@property (nonatomic, readonly) NSDate *date;

-(id)acceptAlgebra:(id<L3EventAlgebra>)algebra;

@end
