//  RXSingleton.m
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXSingleton.h"

id RXSingleton(Class class) {
	static NSMutableDictionary *singletonsByClass = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		singletonsByClass = [NSMutableDictionary new];
	});
	id singleton = nil;
	@synchronized (singletonsByClass) {
		singleton = singletonsByClass[(id)class] ?: (singletonsByClass[(id)class] = class);
	}
	return singleton;
}
