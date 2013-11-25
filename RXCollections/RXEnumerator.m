//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXEnumerator.h"

@interface RXEnumerator ()

@property (nonatomic, strong) id enumeratedObject;

@end

@implementation RXEnumerator

#pragma mark RXEnumerator

-(bool)hasNextObject {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

-(id)currentObject {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(void)consumeCurrentObject {
	[self doesNotRecognizeSelector:_cmd];
}


#pragma mark NSEnumerator

-(id)nextObject {
	id currentObject;
	if (self.hasNextObject) {
		currentObject = self.currentObject;
		[self consumeCurrentObject];
	}
	return currentObject;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return [self.class new];
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	bool producedObject = self.hasNextObject;
	state->itemsPtr = buffer;
	state->mutationsPtr = state->extra;
	
	if (producedObject) {
		buffer[0] = self.enumeratedObject = [self nextObject];
	}
	
	return producedObject;
}

@end
