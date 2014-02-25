//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXGenerator.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

@interface RXGeneratorTraversable : NSObject <RXGenerator>

+(instancetype)generatorWithContext:(id<NSObject, NSCopying>)context block:(RXGeneratorBlock)block;

@property (nonatomic, readonly) id nextObject;
@property (nonatomic, getter = isComplete, readwrite) bool complete;
@property (nonatomic, copy, readonly) RXGeneratorBlock block;
@end

@implementation RXGeneratorTraversable

@synthesize context = _context;

#pragma mark Construction

+(instancetype)generatorWithContext:(id<NSObject, NSCopying>)context block:(RXGeneratorBlock)block {
	return [[self alloc] initWithContext:context block:block];
}

-(instancetype)initWithContext:(id<NSObject, NSCopying>)context block:(RXGeneratorBlock)block {
	if ((self = [super init])) {
		_context = context;
		_block = [block copy];
	}
	return self;
}

l3_test(@selector(traversal), ^{
	RXGeneratorBlock fibonacci = ^(RXGeneratorTraversable *self) {
		NSNumber *previous = self.context[1], *next = @([self.context[0] unsignedIntegerValue] + [previous unsignedIntegerValue]);
		self.context = (id)[RXTuple tupleWithArray:@[previous, next]];
		return previous;
	};
	NSMutableArray *series = [NSMutableArray new];
	for (NSNumber *number in RXGenerator([RXTuple tupleWithArray:@[@0, @1]], fibonacci).traversal) {
		[series addObject:number];
		if (series.count == 12)
			break;
	}
	l3_expect(series).to.equal(@[@1, @1, @2, @3, @5, @8, @13, @21, @34, @55, @89, @144]);
	
	NSUInteger n = 3;
	RXGeneratorBlock block = ^(RXGeneratorTraversable *self) {
		NSUInteger current = [(NSNumber *)self.context unsignedIntegerValue];
		self.context = @(current + 1);
		if (current >= n)
			[self complete];
		return @(current);
	};
	NSArray *integers = RXConstructArray(RXGenerator(nil, block).traversal);
	l3_expect(integers).to.equal(@[@0, @1, @2, @3]);
})

-(id<RXTraversal>)traversal {
	return RXTraversalWithSource(^bool(id<RXRefillableTraversal> traversal) {
		[traversal addObject:[self nextObject]];
		return self.isComplete;
	});
}


-(id)nextObject {
	return self.block(self);
}

-(bool)isComplete {
	return _complete;
}

-(void)complete {
	self.complete = YES;
}

@end

id<RXGenerator> RXGenerator(id<NSObject, NSCopying> context, RXGeneratorBlock block) {
	return [RXGeneratorTraversable generatorWithContext:context block:block];
}
