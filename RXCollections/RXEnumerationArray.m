//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXInterval.h"
#import "RXEnumerationArray.h"
#import "RXTraversal.h"

#import <Lagrangian/Lagrangian.h>

@interface RXEnumerationArray ()

@property (nonatomic, strong) id<NSObject, NSFastEnumeration> enumeration;
@property (nonatomic, assign) NSUInteger internalCount;
@property (nonatomic, assign) NSUInteger enumeratedCount;
@property (nonatomic, assign) NSUInteger processedCount;
@property (nonatomic, assign, readonly) NSFastEnumerationState state;
@property (nonatomic, strong) NSMutableArray *enumeratedObjects;

@end

@implementation RXEnumerationArray

#pragma mark Construction

+(instancetype)arrayWithEnumeration:(id<NSObject, NSFastEnumeration>)enumeration count:(NSUInteger)count {
	return [[self alloc] initWithEnumeration:enumeration count:count];
}

+(instancetype)arrayWithEnumeration:(id<NSObject, NSFastEnumeration>)enumeration {
	return [self arrayWithEnumeration:enumeration count:RXTraversalUnknownCount];
}

-(instancetype)initWithEnumeration:(id<NSObject, NSFastEnumeration>)traversal count:(NSUInteger)count {
	if ((self = [super init])) {
		_enumeration = traversal;
		if ((count == RXTraversalUnknownCount) && ([traversal conformsToProtocol:@protocol(RXFiniteTraversal)]))
			_internalCount = [(id<RXFiniteTraversal>)traversal count];
		else
			_internalCount = count;
	}
	return self;
}


#pragma mark NSArray primitives

l3_test(@selector(count), ^{
	id<RXFiniteEnumerator> items = [RXIntervalEnumerator enumeratorWithInterval:(RXInterval){0, 63}];
	RXEnumerationArray *array = [RXEnumerationArray arrayWithEnumeration:items count:items.count];
	[array count];
	l3_expect(array.enumeratedObjects).to.equal(nil);
	
	array = [RXEnumerationArray arrayWithEnumeration:[@[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, @21, @22, @23, @24, @25, @26, @27, @28, @29, @30, @31, @32, @33, @34, @35, @36, @37, @38, @39, @40, @41, @42, @43, @44, @45, @46, @47, @48, @49, @50, @51, @52, @53, @54, @55, @56, @57, @58, @59, @60, @61, @62, @63] objectEnumerator]];
	[array count];
	l3_expect(array.enumeratedObjects.count).to.equal(@64);
})

-(NSUInteger)count {
	if (self.internalCount == RXTraversalUnknownCount)
		[self populateUpToIndex:NSUIntegerMax];
	return self.internalCount;
}

l3_test(@selector(objectAtIndex:), ^{
	RXEnumerationArray *array = [RXEnumerationArray arrayWithEnumeration:[RXIntervalEnumerator enumeratorWithInterval:(RXInterval){0, 63}]];
	[array objectAtIndex:0];
	l3_expect(array.enumeratedObjects.count).to.equal(@16);
	[array objectAtIndex:15];
	l3_expect(array.enumeratedObjects.count).to.equal(@16);
	[array objectAtIndex:16];
	l3_expect(array.enumeratedObjects.count).to.equal(@32);
})

-(id)objectAtIndex:(NSUInteger)index {
	[self populateUpToIndex:index];
	return self.enumeratedObjects[index];
}


#pragma mark Populating

l3_test(@selector(populateUpToIndex:), ^{
	RXEnumerationArray *array = [RXEnumerationArray arrayWithEnumeration:[RXIntervalEnumerator enumeratorWithInterval:(RXInterval){0, 63}]];
	[array populateUpToIndex:NSUIntegerMax];
	l3_expect(array.enumeration).to.equal(nil);
})

-(void)populateUpToIndex:(NSUInteger)index {
	if (!self.enumeration || self.enumeratedObjects.count > index)
		return;
	
	if (!self.enumeratedObjects)
		self.enumeratedObjects = [NSMutableArray new];
	
	__unsafe_unretained id objects[16];
	const NSUInteger kChunkCount = sizeof objects / sizeof *objects;
	while (self.enumeratedObjects.count <= index) {
		if (self.processedCount == self.enumeratedCount) {
			self.processedCount = 0;
			self.enumeratedCount = [self.enumeration countByEnumeratingWithState:&_state objects:objects count:kChunkCount];
			if (self.enumeratedCount == 0) {
				self.internalCount = self.enumeratedObjects.count;
				self.enumeration = nil;
				break;
			}
		}
		
		NSUInteger count = MIN(self.enumeratedCount, (index == RXTraversalUnknownCount)? NSUIntegerMax : (ceil((index + 1) / (double)kChunkCount) * kChunkCount));
		
		for (NSUInteger i = 0; i < count; i++) {
			[self.enumeratedObjects addObject:self.state.itemsPtr[i + self.processedCount]];
		}
		
		self.processedCount += count;
	}
}


#pragma mark NSFastEnumeration

l3_test(@selector(countByEnumeratingWithState:objects:count:), ^{
	RXEnumerationArray *array = [RXEnumerationArray arrayWithEnumeration:[RXIntervalEnumerator enumeratorWithInterval:(RXInterval){0, 63}]];
	for (id x in array) { break; }
	l3_expect(array.enumeratedObjects.count).to.equal(@16);
	for (id x in array) { break; }
	l3_expect(array.enumeratedObjects.count).to.equal(@16);
	for (id x in array) {}
	l3_expect(array.enumeratedObjects.count).to.equal(@64);
})

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	NSUInteger count = 0;
	if (state->state != self.internalCount) {
		state->itemsPtr = buffer;
		
		[self populateUpToIndex:state->state + len - 1];
		if (self.enumeration)
			state->mutationsPtr = self.state.mutationsPtr;
		else
			state->mutationsPtr = state->extra;
		
		count = MIN(len, self.enumeratedObjects.count - state->state);
		[self.enumeratedObjects getObjects:buffer range:NSMakeRange(state->state, count)];
		state->state += count;
	}
	
	return count;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}

@end
