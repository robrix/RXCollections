//  L3StringInflections.h
//  Created by Rob Rix on 2012-11-14.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface L3StringInflections : NSObject

+(NSString *)pluralizeNoun:(NSString *)noun count:(NSUInteger)count;
+(NSString *)cardinalizeNoun:(NSString *)noun count:(NSUInteger)count;

@end
