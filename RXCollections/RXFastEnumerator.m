//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFastEnumerator.h"

#import <Lagrangian/Lagrangian.h>

@interface RXFastEnumerator ()

@property (nonatomic, readonly) id<NSObject, NSFastEnumeration> enumeration;

@end

@implementation RXFastEnumerator {
	NSFastEnumerationState _state;
	id __unsafe_unretained _objects[16];
	NSUInteger _countProduced;
	id __unsafe_unretained *_items;
}

-(instancetype)initWithEnumeration:(id<NSObject, NSFastEnumeration>)enumeration {
	NSParameterAssert(enumeration != nil);
	
	if ((self = [super init])) {
		_enumeration = enumeration;
	}
	return self;
}


l3_test(@selector(needsToFetchItems), ^{
	RXFastEnumerator *enumerator = [[RXFastEnumerator alloc] initWithEnumeration:@[@1, @2, @3, @4]];
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
	RXFastEnumerator *enumerator = [[RXFastEnumerator alloc] initWithEnumeration:[@[@1, @2] objectEnumerator]];
	
	l3_expect([enumerator nextObject]).to.equal(@1);
	l3_expect([enumerator nextObject]).to.equal(@2);
	l3_expect([enumerator nextObject]).to.equal(nil);
})

-(void)consumeCountItems:(NSUInteger)count {
	[self fetchItemsIfNeeded];
	
	if (_items != NULL) {
		_items += count;
	}
}


#pragma mark RXEnumerator

-(bool)hasNextObject {
	[self fetchItemsIfNeeded];
	
	return _items != NULL;
}

-(id)currentObject {
	[self fetchItemsIfNeeded];
	
	return _items? *_items : nil;
}

-(void)consumeCurrentObject {
	[self consumeCountItems:1];
}


#pragma mark NSEnumerator

-(id)nextObject {
	[self fetchItemsIfNeeded];
	
	id currentObject;
	if (self.hasNextObject) {
		currentObject = self.currentObject;
		[self consumeCountItems:1];
	}
	return currentObject;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	id<NSObject, NSFastEnumeration> enumeration = [_enumeration respondsToSelector:@selector(copyWithZone:)]?
		[(id<NSCopying>)_enumeration copyWithZone:zone]
	:	_enumeration;
	RXFastEnumerator *copy = [[self.class alloc] initWithEnumeration:enumeration];
	copy->_state = _state;
	
	memcpy(copy->_objects, _objects, sizeof _objects);
	copy->_countProduced = _countProduced;
	copy->_items = _items;
	return copy;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	[self fetchItemsIfNeeded];
	
	state->itemsPtr = _items;
	state->mutationsPtr = _state.mutationsPtr;
	NSUInteger count = self.countOfRemainingObjects;
	[self consumeCountItems:count];
	
	return count;
}

@end
