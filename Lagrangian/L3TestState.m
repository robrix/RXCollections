//  L3TestState.m
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestState.h"

@interface L3TestState ()

@property (nonatomic, readonly) NSMutableDictionary *contents;

@end

@implementation L3TestState

-(instancetype)init {
	if((self = [super init])) {
		_contents = [NSMutableDictionary new];
	}
	return self;
}


-(id)objectForKeyedSubscript:(NSString *)key {
	return self.contents[key];
}

-(void)setObject:(id)object forKeyedSubscript:(NSString *)key {
	self.contents[key] = object;
}

@end
