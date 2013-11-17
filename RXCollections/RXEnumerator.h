//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

/**
 A copyable enumerator.
 */
@protocol RXEnumerator <NSObject, NSCopying, NSFastEnumeration>

@property (nonatomic, readonly) bool isExhausted;
@property (nonatomic, readonly) id currentObject;
-(void)consumeCurrentObject;

@end


/**
 An enumerator which has a known length.
 */
@protocol RXFiniteEnumerator <RXEnumerator>

@property (nonatomic, readonly) NSUInteger length;

@end


/**
 An enumerator which does not have a known length.
 */
@protocol RXInfiniteEnumerator <RXEnumerator>
@end



/**
 An enumerator which can be read from at indices.
 */
@protocol RXIndexedEnumerator <RXEnumerator>

-(id)objectAtIndexedSubscript:(NSUInteger)index;

-(instancetype)subrangeFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

@end


/**
 An enumerator which can be written to.
 */
@protocol RXOutputEnumerator <RXEnumerator>

@property (nonatomic) id currentObject;

@end


/**
 An enumerator which can be written to at arbitrary indices.
 */
@protocol RXIndexedOutputEnumerator <RXIndexedEnumerator, RXOutputEnumerator>

-(void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;

@end
