//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXBatchEnumerator.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

@implementation RXBatchEnumerator {
	id __strong *_batch;
	id __strong *_current;
	id __strong *_stop;
	id __strong *_capacity;
}

+(NSUInteger)defaultCapacity {
	return 16;
}

-(instancetype)initWithCapacity:(NSUInteger)capacity {
	NSParameterAssert(capacity > 0);
	
	if ((self = [super init])) {
		_batch = (id __strong *)calloc(capacity, sizeof(id));
		_capacity = _batch + capacity;
		_current = _stop = _capacity;
	}
	return self;
}

-(instancetype)init {
	return [self initWithCapacity:self.class.defaultCapacity];
}

-(void)dealloc {
	[self _clear:_batch];
	free(_batch);
	_batch = _current = _stop = _capacity = NULL;
}


#pragma mark Batching

-(void)_refillIfNeeded {
	if (_batch != _capacity && _stop <= _current) {
		_stop = _batch + [self countOfObjectsProducedInBatch:_batch count:_capacity - _batch];
		_current = _batch;
		if (_stop == _batch) {
			free(_batch);
			_batch = _current = _stop = _capacity = NULL;
		}
	}
}

-(NSUInteger)_countRemaining {
	return _stop - _current;
}

-(void)_consumeCount:(NSUInteger)countConsumed {
	NSParameterAssert(countConsumed <= self._countRemaining);
	
	_current += countConsumed;
}

-(void)_clear:(id __strong [])batch {
	NSParameterAssert(batch <= _capacity);
	
	for (; batch < _capacity; batch++) {
		*batch = nil;
	}
}

-(NSUInteger)countOfObjectsProducedInBatch:(__strong id [])batch count:(NSUInteger)count {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}


#pragma mark RXEnumerator

-(bool)isEmpty {
	return _batch == _capacity;
}

-(id)currentObject {
	[self _refillIfNeeded];
	
	return self.isEmpty?
		nil
	:	*_current;
}

-(void)consumeCurrentObject {
	[self _consumeCount:1];
	*_current = nil;
}


#pragma mark NSEnumerator

-(id)nextObject {
	[self _refillIfNeeded];
	
	id currentObject;
	if (self._countRemaining > 0) {
		currentObject = *_current;
		[self consumeCurrentObject];
	}
	return currentObject;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXBatchEnumerator *copy = [[self.class alloc] init];
	copy->_current = copy->_batch;
	copy->_stop = copy->_batch + self._countRemaining;
	
	for (id __strong *me = self->_current, *them = copy->_current; me < _stop;) {
		*them++ = *me++;
	}
	
	return copy;
}


#pragma mark NSFastEnumeration

typedef struct {
	unsigned long state;
    id const *itemsPtr;
    unsigned long *mutationsPtr;
} RXBatchEnumeratorState;

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)uncastState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXBatchEnumeratorState *state = (RXBatchEnumeratorState *)uncastState;
	
	[self _refillIfNeeded];
	
	state->itemsPtr = _batch;
	state->mutationsPtr = (unsigned long *)&state->mutationsPtr;
	
	NSUInteger count = self._countRemaining;
	[self _consumeCount:count];
	[self _clear:_stop];
	
	return count;
}

@end
