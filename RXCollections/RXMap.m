//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMap.h"
#import "RXFastEnumerator.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

@interface RXMapEnumerator : RXEnumerator <RXEnumerator>

-(instancetype)initWithEnumerator:(id<RXEnumerator>)enumerator block:(RXMapBlock)block;

@property (nonatomic, readonly) id<RXEnumerator> enumerator;
@property (nonatomic, copy, readonly) RXMapBlock block;

@end


l3_addTestSubjectTypeWithBlock(RXMapBlock)
l3_addTestSubjectTypeWithFunction(RXMap)

l3_test(RXIdentityMapBlock, ^{
	bool stop = NO;
	l3_expect(RXIdentityMapBlock(@"Equestrian", &stop)).to.equal(@"Equestrian");
})

RXMapBlock const RXIdentityMapBlock = ^(id x, bool *stop) {
	return x;
};


l3_test(&RXMap, ^{
	id mapped = RXConstructArray(RXMap(@[@"Hegemony", @"Maleficent"], ^(NSString *each, bool *stop) {
		return [each stringByAppendingString:@"Superlative"];
	}));
	l3_expect(mapped).to.equal(@[@"HegemonySuperlative", @"MaleficentSuperlative"]);
})

id<RXEnumerator> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block) {
	return [[RXMapEnumerator alloc] initWithEnumerator:RXEnumeratorWithEnumeration(enumeration) block:block];
}


@implementation RXMapEnumerator {
	bool _stop;
}

-(instancetype)initWithEnumerator:(id<RXEnumerator>)enumerator block:(RXMapBlock)block {
	NSParameterAssert(enumerator != nil);
	NSParameterAssert(block != nil);
	
	if ((self = [super init])) {
		_enumerator = enumerator;
		_block = [block copy];
	}
	return self;
}


-(bool)hasNextObject {
	return !_stop && self.enumerator.hasNextObject;
}

@synthesize currentObject = _currentObject;

-(id)currentObject {
	if (!_currentObject) {
		_currentObject = self.block(self.enumerator.currentObject, &_stop);
	}
	return _stop? nil : _currentObject;
}

-(void)consumeCurrentObject {
	[self.enumerator consumeCurrentObject];
	_currentObject = nil;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXMapEnumerator *copy = [super copyWithZone:zone];
	copy->_stop = _stop;
	return copy;
}

@end
