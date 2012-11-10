//  L3TestState.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface L3TestState : NSObject

// subscripting support for arbitrary object state
-(id)objectForKeyedSubscript:(NSString *)key;
-(void)setObject:(id)object forKeyedSubscript:(NSString *)key;

@end
