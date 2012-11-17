//  L3Collection.h
//  Created by Rob Rix on 2012-11-17.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@protocol L3Collection <NSFastEnumeration, NSObject>

+(instancetype)l3_empty;
+(instancetype)l3_wrap:(id)element;

// what Objective-C can’t express here is that the other should have the same type
-(instancetype)l3_appendCollection:(id<L3Collection>)other;

@end

@interface NSArray (L3Collection) <L3Collection>
@end

@interface NSSet (L3Collection) <L3Collection>
@end

@interface NSDictionary (L3Collection) <L3Collection>
@end
