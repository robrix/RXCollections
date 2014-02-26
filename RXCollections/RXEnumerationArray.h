//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

@interface RXEnumerationArray : NSArray

+(instancetype)arrayWithEnumeration:(id<NSObject, NSCopying, NSFastEnumeration>)enumeration;
+(instancetype)arrayWithEnumeration:(id<NSObject, NSCopying, NSFastEnumeration>)enumeration count:(NSUInteger)count;

@end
