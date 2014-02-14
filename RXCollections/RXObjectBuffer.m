//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXObjectBuffer.h"
#import <Lagrangian/Lagrangian.h>

@interface RXObjectBuffer ()

@property (nonatomic) NSUInteger start;
@property (nonatomic) NSUInteger end;
@property (nonatomic) NSInteger enqueueCount;
@property (nonatomic) NSInteger dequeueCount;
@property (nonatomic, readonly) id __strong *objects;

@end

@implementation RXObjectBuffer

-(instancetype)initWithCapacity:(NSUInteger)capacity {
	if ((self = [super init])) {
		_capacity = capacity;
		_objects = (id __strong *)calloc(capacity, sizeof(id __strong));
	}
	return self;
}

-(void)dealloc {
	for (NSUInteger i = 0; i < _capacity; i++) {
		_objects[i] = nil;
	}
	free(_objects);
}


l3_test(@selector(enqueueObject:), ^{
	RXObjectBuffer *buffer = [[RXObjectBuffer alloc] initWithCapacity:4];
	
	[buffer enqueueObject:@"Simplex"];
	l3_expect(buffer.count).to.equal(@1);
	l3_expect(buffer.currentObject).to.equal(@"Simplex");
	
	[buffer enqueueObject:@"Weathering"];
	l3_expect(buffer.count).to.equal(@2);
	l3_expect(buffer.currentObject).to.equal(@"Simplex");
})

-(void)enqueueObject:(id)object {
	self.objects[self.end] = object;
	
	self.end = (self.end + 1) % self.capacity;
	self.enqueueCount++;
}

l3_test(@selector(dequeueObject), ^{
	RXObjectBuffer *buffer = [[RXObjectBuffer alloc] initWithCapacity:4];
	[buffer enqueueObject:@"Jocular"];
	[buffer enqueueObject:@"Erstwhile"];
	
	l3_expect([buffer dequeueObject]).to.equal(@"Jocular");
	l3_expect(buffer.count).to.equal(@1);
	l3_expect(buffer.currentObject).to.equal(@"Erstwhile");
	
	l3_expect([buffer dequeueObject]).to.equal(@"Erstwhile");
	l3_expect(buffer.count).to.equal(@0);
})

-(id)dequeueObject {
	id object = self.currentObject;
	self.objects[self.start] = nil;
	
	self.dequeueCount++;
	self.start = (self.start + 1) % self.capacity;
	return object;
}

l3_test(@selector(isFull), ^{
	RXObjectBuffer *buffer = [[RXObjectBuffer alloc] initWithCapacity:2];
	l3_expect(buffer.isFull).to.equal(@NO);
	[buffer enqueueObject:@"Preparatory"];
	l3_expect(buffer.isFull).to.equal(@NO);
	[buffer enqueueObject:@"Ultimatum"];
	l3_expect(buffer.isFull).to.equal(@YES);
})

-(bool)isFull {
	return self.count == self.capacity;
}


#pragma mark RXEnumerator

l3_test(@selector(hasNextObject), ^{
	RXObjectBuffer *buffer = [[RXObjectBuffer alloc] initWithCapacity:2];
	l3_expect(buffer.hasNextObject).to.equal(@NO);
	[buffer enqueueObject:@"Lackadaisical"];
	l3_expect(buffer.hasNextObject).to.equal(@YES);
	[buffer enqueueObject:@"Arduous"];
	l3_expect(buffer.hasNextObject).to.equal(@YES);
})

-(bool)hasNextObject {
	return self.count > 0;
}

-(id)currentObject {
	return self.objects[self.start];
}

-(void)setCurrentObject:(id)currentObject {
	[self enqueueObject:currentObject];
}

-(void)consumeCurrentObject {
	[self dequeueObject];
}


#pragma mark RXFiniteEnumerator

-(NSUInteger)count {
	return labs(self.enqueueCount - self.dequeueCount);
}


#pragma mark NSEnumerator

-(id)nextObject {
	id currentObject = self.currentObject;
	[self consumeCurrentObject];
	return currentObject;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXObjectBuffer *copy = [[self.class alloc] initWithCapacity:self.capacity];
	NSUInteger start = self.start;
	NSUInteger capacity = self.capacity;
	NSUInteger count = self.count;
	id __strong *objects = self.objects;
	for (NSUInteger i = 0; i < count; i++) {
		[copy enqueueObject:objects[(start + i) % capacity]];
	}
	return copy;
}

@end
