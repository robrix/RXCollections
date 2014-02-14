//  RXAllocation.h
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

@interface NSObject (RXAllocation)

+(instancetype)allocateWithExtraSize:(size_t)extraSize;

@property (nonatomic, readonly) void *extraSpace;

@end
