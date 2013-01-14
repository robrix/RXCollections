//  RXPair.m
//  Created by Rob Rix on 2013-01-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXPair.h"

@implementation RXPair

+(instancetype)pairWithLeft:(id)left right:(id)right {
	RXPair *pair = [self new];
	pair.left = left;
	pair.right = right;
	return pair;
}

@end


@implementation RXPair (RXPairNSDictionaryConvenience)

+(instancetype)pairWithKey:(id<NSCopying>)key value:(id)value {
	RXPair *pair = [self new];
	pair.key = key;
	pair.value = value;
	return pair;
}


-(id<NSCopying>)key {
	return self.left;
}

-(void)setKey:(id<NSCopying>)key {
	// fixme: should this copy?
	self.left = key;
}


-(id)value {
	return self.right;
}

-(void)setValue:(id)value {
	self.right = value;
}

@end
