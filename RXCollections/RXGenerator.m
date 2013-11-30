//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXGenerator.h"
#import "RXMap.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

@interface RXGenerator ()

@property (nonatomic, copy, readonly) RXGeneratorBlock block;

@end

@implementation RXGenerator

-(instancetype)initWithBlock:(RXGeneratorBlock)block {
	if ((self = [super init])) {
		_block = [block copy];
	}
	return self;
}


#pragma mark RXEnumerator

l3_test(@selector(nextObject), ^{
	__block NSUInteger previous = 1;
	__block NSUInteger current = 0;
	RXGenerator *fibonacci = [[RXGenerator alloc] initWithBlock:^id(RXGenerator *generator) {
		NSUInteger next = previous + current;
		previous = current;
		current = next;
		return @(next);
	}];
	
	NSArray *expected = @[@1, @1, @2, @3, @5, @8, @13, @21, @34, @55, @89, @144];
	__block NSUInteger n = 0;
	NSArray *computed = RXConstructArray(RXMap(fibonacci, ^id(id each){
		if (n++ == 12) return nil;
		return each;
	}));
	
	l3_expect(computed).to.equal(expected);
})

-(id)nextObject {
	return self.block(self);
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXGenerator *copy = [super copyWithZone:zone];
	copy->_block = [_block copy];
	return copy;
}

@end
