//  RXFastEnumerationState.h
//  Created by Rob Rix on 2013-03-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@protocol RXFastEnumerationState <NSObject>

@property (nonatomic, readonly) NSFastEnumerationState *NSFastEnumerationState;

@property (nonatomic, assign) __autoreleasing id *items;
@property (nonatomic, assign) __unsafe_unretained id *itemsBuffer;
@property (nonatomic, assign) const id *constItems;
@property (nonatomic, assign) unsigned long *mutations;

@end

/**
 RXFastEnumerationState : NSObject
 
 RXFastEnumerationState is expected to be used in classes implementing NSFastEnumeration, via purpose-specific subclasses which add any extra state necessary (up to five words such) as properties.
 
 Using RXFastEnumerationState is intended to ease the storage of autoreleased objects into an NSFastEnumerationState structure and otherwise simplify the implementation of NSFastEnumeration when you are doing anything more complex than trivially storing an object-lifetime interior pointer into it.
 */
@interface RXFastEnumerationState : NSObject <RXFastEnumerationState>

/**
 +stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count initializationHandler:(void(^)(id state))block
 
 Returns the NSFastEnumerationState cast to RXFastEnumerationState or the receiving subclass and with a pointer to the receiving class in the state field (effectively an isa pointer). This method returns a retained instance (hence the NS_RETURNS_RETAINED markup), because by the time the autorelease pool has been popped the underlying state will have gone away and the object would be invalid, leading to a crash in objc_release.
 
 The underlying state's mutations pointer is set to point at the isa pointer, which is an appropriate choice for enumerations of immutable collections whose state subclass is not expected to change between calls to -countByEnumeratingWithState:objects:count:.
 
 This method also calls the passed block the first time it is applied to a given state pointer; this block (or the caller) is welcome to reassign the mutations address to a more appropriate value.
 */
+(id<RXFastEnumerationState>)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count initializationHandler:(void(^)(id<RXFastEnumerationState> state))block NS_RETURNS_RETAINED;

@end

@interface RXHeapFastEnumerationState : NSObject <RXFastEnumerationState>

/**
 +state
 
 Returns a new NSFastEnumerationState-sized RXFastEnumerationState instance suitable for use by callers of -countByEnumeratingWithState:objects:count:that need a heap-allocated, ARC-manageable state instance.
 */
+(instancetype)state;

@end
