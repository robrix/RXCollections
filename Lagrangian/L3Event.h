//  L3Event.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventVisitor.h"
#import "L3EventSource.h"

@protocol L3Event <NSObject>

@property (nonatomic, readonly) NSDate *date;

@end

@interface L3Event : NSObject <L3Event>

+(instancetype)eventWithSource:(id<L3EventSource>)source;
-(instancetype)initWithSource:(id<L3EventSource>)source;

@property (strong, nonatomic, readonly) id<L3EventSource> source;

-(id)acceptVisitor:(id<L3EventVisitor>)visitor;

@end

// suite started
// suite ended
// test started
// test ended
// assertion passed
// assertion failed
// assertion failed unexpectedly (exception)
