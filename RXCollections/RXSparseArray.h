//  RXSparseArray.h
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface RXSparseArray : NSArray <NSCopying, NSMutableCopying, NSFastEnumeration>

+(instancetype)arrayWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count;

/**
 Creates a sparse array with the given objects at the specific indices.
 */
-(instancetype)initWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count;

/**
 The count of the sparse array, defined as 1 + its greatest assigned index.
 
 This definition was selected over the number of elements within the array (\c elementCount) to allow backwards-compatibility with common idioms to iterate arrays densely by index.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 The number of elements in this array.
 
 This exists in contrast to the extent of the span of indices that the array covers (\c count).
 */
@property (nonatomic, readonly) NSUInteger elementCount;

/**
 Returns the object at a specified index, if any.
 
 @return The object stored for the specified index, or nil if there is none. Note that this differs from NSArray's behaviour: RXSparseArray does not throw an exception for out of bounds indices, and can contain nil.
 */
-(id)objectAtIndex:(NSUInteger)index;

@end


@interface RXMutableSparseArray : NSMutableArray

+(instancetype)arrayWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count;

-(instancetype)initWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count;

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger elementCount;

-(id)objectAtIndex:(NSUInteger)index;

-(void)insertObject:(id)anObject atIndex:(NSUInteger)index;
-(void)removeObjectAtIndex:(NSUInteger)index;
-(void)addObject:(id)anObject;
-(void)removeLastObject;
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end
