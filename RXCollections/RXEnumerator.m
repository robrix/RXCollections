//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXEnumerator.h"

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

@end
