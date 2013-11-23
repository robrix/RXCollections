//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

@interface RXFastEnumerator : NSEnumerator

-(instancetype)initWithEnumeration:(id<NSFastEnumeration>)enumeration;

@end
