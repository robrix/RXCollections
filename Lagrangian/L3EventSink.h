//  L3EventSink.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventAlgebra.h"

@class L3Event;
@protocol L3EventSinkDelegate;

@interface L3EventSink : NSObject <L3EventAlgebra>

@property (weak, nonatomic) id<L3EventSinkDelegate> delegate;

@property (copy, nonatomic, readonly) NSArray *events;

@end

@protocol L3EventSinkDelegate <NSObject>

-(void)eventSink:(L3EventSink *)eventSink didAddEvent:(L3Event *)event;

@end
