//  RXNilArray.h
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

@interface RXNilArray : NSArray

-(instancetype)initWithObjects:(const id [])objects count:(NSUInteger)count;

@property (nonatomic, readonly) NSUInteger count;

@end


@interface RXMutableNilArray : NSMutableArray

-(instancetype)initWithObjects:(const id [])objects count:(NSUInteger)count;

@property (nonatomic, readonly) NSUInteger count;

@end
