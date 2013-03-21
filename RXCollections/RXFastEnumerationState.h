//  RXFastEnumerationState.h
//  Created by Rob Rix on 2013-03-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface RXFastEnumerationState : NSObject

@property (nonatomic, assign) __autoreleasing id *items;
@property (nonatomic, assign) unsigned long *mutations;

@end
