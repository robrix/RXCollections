//  RXFastEnumerationState.h
//  Created by Rob Rix on 2013-03-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface RXFastEnumerationState : NSObject

/**
 +newWithNSFastEnumerationState:(NSFastEnumerationState *)state;
 
 Returns the NSFastEnumerationState cast to RXFastEnumerationState or the receiving subclass and with a pointer to the receiving class in the state field (effectively an isa pointer). This method returns a retained instance (following the +new rule), because by the time the autorelease pool has been popped the underlying state will have gone away and the object would be invalid, leading to a crash in objc_release.
 
 To reiterate: if you are using this method, you must ensure that the instance is not autoreleased. Such is the cost of an effectively stack-allocated instance.
 */
+(instancetype)newWithNSFastEnumerationState:(NSFastEnumerationState *)state;

@property (nonatomic, assign) __autoreleasing id *items;
@property (nonatomic, assign) __unsafe_unretained id *itemsBuffer;
@property (nonatomic, assign) unsigned long *mutations;

@end
