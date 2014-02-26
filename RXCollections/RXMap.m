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


//l3_addTestSubjectTypeWithBlock(RXMapBlock);

l3_test(RXIdentityMapBlock, ^{
	l3_expect(RXIdentityMapBlock(@"Equestrian")).to.equal(@"Equestrian");
})

RXMapBlock const RXIdentityMapBlock = ^(id x) {
	return x;
};


l3_addTestSubjectTypeWithFunction(RXMap);

l3_test(&RXMap, ^{
	id mapped = RXConstructArray(RXMap(@[@"Hegemony", @"Maleficent"], ^(NSString *each) {
		return [each stringByAppendingString:@"Superlative"];
	}));
	l3_expect(mapped).to.equal(@[@"HegemonySuperlative", @"MaleficentSuperlative"]);
})

id<RXEnumerator> RXMap(id<NSObject, NSCopying, NSFastEnumeration> enumeration, RXMapBlock block) {
	return [[RXMapEnumerator alloc] initWithEnumerator:RXEnumeratorWithEnumeration(enumeration) block:block];
}


@implementation RXMapEnumerator

-(instancetype)initWithEnumerator:(id<RXEnumerator>)enumerator block:(RXMapBlock)block {
	NSParameterAssert(enumerator != nil);
	NSParameterAssert(block != nil);
	
	if ((self = [super init])) {
		_enumerator = enumerator;
		_block = [block copy];
	}
	return self;
}


#pragma mark RXEnumerator

-(id)map:(id)object {
	id mapped = _block && object? _block(object) : nil;
	if (!mapped) {
		_enumerator = nil;
	}
	return mapped;
}

-(id)nextObject {
	return [self map:[self.enumerator nextObject]];
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXMapEnumerator *copy = [super copyWithZone:zone];
	copy->_enumerator = [_enumerator copyWithZone:zone];
	copy->_block = [_block copyWithZone:zone];
	return copy;
}

@end
