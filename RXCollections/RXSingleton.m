//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXAllocation.h"
#import "RXSingleton.h"

id RXSingleton(Class class, id(^initializer)()) {
	static NSMutableDictionary *singletonsByClass = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		singletonsByClass = [NSMutableDictionary new];
	});
	id singleton = nil;
	@synchronized (singletonsByClass) {
		singleton = singletonsByClass[(id)class] ?: (singletonsByClass[(id)class] = initializer());
	}
	return singleton;
}
