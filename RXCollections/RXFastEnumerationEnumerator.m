//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFastEnumerationEnumerator.h"

#import <Lagrangian/Lagrangian.h>

@interface RXFastEnumerationEnumerator ()

@property (nonatomic, readonly) id<NSFastEnumeration> enumeration;

@end

@implementation RXFastEnumerationEnumerator {
	NSFastEnumerationState _state;
	id __unsafe_unretained _objects[16];
	NSUInteger _countProduced;
	id __unsafe_unretained *_items;
}

-(instancetype)initWithEnumeration:(id<NSFastEnumeration>)enumeration {
	NSParameterAssert(enumeration != nil);
	
	if ((self = [super init])) {
		_enumeration = enumeration;
	}
	return self;
}


l3_test(@selector(needsToFetchItems), ^{
	RXFastEnumerationEnumerator *enumerator = [[RXFastEnumerationEnumerator alloc] initWithEnumeration:@[@1, @2, @3, @4]];
	l3_expect(enumerator.needsToFetchItems).to.equal(@YES);
	[enumerator fetchItemsIfNeeded];
	l3_expect(enumerator.needsToFetchItems).to.equal(@NO);
})

-(bool)needsToFetchItems {
	return
		self.enumeration != nil
	&&	self.countOfRemainingObjects == 0;
}

-(id __unsafe_unretained *)fetchItemsIfNeeded {
	return self.needsToFetchItems?
		[self fetchItems]
	:	_items;
}

-(id __unsafe_unretained *)fetchItems {
	_countProduced = [self.enumeration countByEnumeratingWithState:&_state objects:_objects count:sizeof _objects / sizeof *_objects];
	if (_countProduced > 0) {
		_items = _state.itemsPtr;
	} else {
		_enumeration = nil;
		_items = NULL;
	}
	return _items;
}

-(NSUInteger)countOfRemainingObjects {
	return _countProduced - (_items - _state.itemsPtr);
}


l3_test(@selector(nextObject), ^{
	RXFastEnumerationEnumerator *enumerator = [[RXFastEnumerationEnumerator alloc] initWithEnumeration:[@[@1, @2] objectEnumerator]];
	
	l3_expect([enumerator nextObject]).to.equal(@1);
	l3_expect([enumerator nextObject]).to.equal(@2);
	l3_expect([enumerator nextObject]).to.equal(nil);
})

-(id __unsafe_unretained *)consumeCountItems:(NSUInteger)count {
	[self fetchItemsIfNeeded];
	
	id __unsafe_unretained *items = _items;
	
	if (_items != NULL) {
		_items += count;
	}
	
	return items ?: NULL;
}


#pragma mark NSEnumerator

-(id)nextObject {
	[self fetchItemsIfNeeded];
	
	id __unsafe_unretained *item = [self consumeCountItems:1];
	return item? *item : nil;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	[self fetchItemsIfNeeded];
	
	state->itemsPtr = [self consumeCountItems:self.countOfRemainingObjects];
	state->mutationsPtr = _state.mutationsPtr;
	
	return self.countOfRemainingObjects;
}

@end
