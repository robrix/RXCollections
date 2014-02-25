//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXPair.h"

@implementation RXTuple (RXPair)

+(instancetype)tupleWithLeft:(id)left right:(id)right {
	return [self tupleWithObjects:(const id []){ left, right } count:2];
}


-(id)left {
	return self[0];
}

-(id)right {
	return self[1];
}

@end


@implementation RXTuple (RXKeyValuePair)

+(instancetype)tupleWithKey:(id<NSCopying>)key value:(id)value {
	return [self tupleWithLeft:key right:value];
}


-(id<NSCopying>)key {
	return self.left;
}

-(id)value {
	return self.right;
}

@end


@implementation RXTuple (RXLinkedListNode)

+(instancetype)tupleWithFirst:(id)first rest:(id)rest {
	return [self tupleWithLeft:first right:rest];
}


-(id)first {
	return self.left;
}

-(id)rest {
	return self.right;
}

@end
