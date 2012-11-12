//  L3EventFormatter.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3Event;

@protocol L3EventFormatter <NSObject>

-(NSString *)formatEvent:(L3Event *)event;

@end
