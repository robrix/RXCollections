//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXEnumerator.h"

const NSUInteger RXEnumeratorUnknownCount = NSUIntegerMax;

@interface RXEnumerator ()

@property (nonatomic, strong) id enumeratedObject;

@end

@implementation RXEnumerator

#pragma mark NSEnumerator

-(id)nextObject {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return [self.class new];
}


#pragma mark NSFastEnumeration

//-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
//	bool producedObject = self.hasNextObject;
//	state->itemsPtr = buffer;
//	state->mutationsPtr = state->extra;
//	
//	if (producedObject) {
//		buffer[0] = self.enumeratedObject = [self nextObject];
//	}
//	
//	return producedObject;
//}

@end
