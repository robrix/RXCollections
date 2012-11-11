//  L3EventSink.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3Event;

@protocol L3EventSink <NSObject>

-(void)addEvent:(L3Event *)event;

@end
