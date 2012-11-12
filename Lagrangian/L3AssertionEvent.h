//  L3AssertionEvent.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Event.h"

@interface L3AssertionEvent : L3Event

+(instancetype)eventWithFile:(NSString *)file line:(NSUInteger)line actualValue:(NSString *)actualValue expectedPattern:(NSString *)expectedPattern source:(id<L3EventSource>)source;

@property (strong, nonatomic, readonly) NSString *file;
@property (assign, nonatomic, readonly) NSUInteger line;

@property (strong, nonatomic, readonly) NSString *actualValue;
@property (strong, nonatomic, readonly) NSString *expectedPattern;

@end
