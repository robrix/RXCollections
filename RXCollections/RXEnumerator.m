//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXEnumerator.h"

@interface RXEnumerator ()

@property (nonatomic, strong) id enumeratedObject;

@end

@implementation RXEnumerator

#pragma mark RXEnumerator

-(bool)isEmpty {
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
	if (!self.isEmpty) {
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
	bool empty = self.isEmpty;
	state->itemsPtr = buffer;
	state->mutationsPtr = state->extra;
	
	if (!empty) {
		buffer[0] = self.enumeratedObject = [self nextObject];
	}
	
	return empty? 0 : 1;
}

@end
