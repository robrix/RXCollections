//  L3Stack.h
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface L3Stack : NSObject

-(void)pushObject:(id)object;
-(id)popObject;

@property (nonatomic, readonly) id topObject;

@property (nonatomic, readonly) NSArray *objects;

@end
