//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

@interface RXEnumerationArray : NSArray

+(instancetype)arrayWithEnumeration:(id<NSObject, NSCopying, NSFastEnumeration>)traversal;
+(instancetype)arrayWithEnumeration:(id<NSObject, NSCopying, NSFastEnumeration>)traversal count:(NSUInteger)count;

@end
