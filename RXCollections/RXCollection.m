//  RXCollection.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import "RXCollection.h"

RXCollectionMapBlock RXCollectionIdentityBlock = ^(id x) { return x; };

@implementation NSObject (RXCollection)

+(id<RXMutableCollection>)rx_emptyMutableCollection {
	return [NSMutableArray array];
}


-(id)rx_foldInitialValue:(id)initial block:(RXCollectionFoldBlock)block {
	for(id each in (id<NSFastEnumeration>)self) {
		initial = block(initial, each);
	}
	return initial;
}

-(id)rx_foldWithBlock:(RXCollectionFoldBlock)block {
	return [self rx_foldInitialValue:nil block:block];
}


-(id)rx_detectWithBlock:(RXCollectionFilterBlock)block {
	for(id each in (id<NSFastEnumeration>)self) {
		if(block(each)) {
			return each;
		}
	}
	return nil;
}


-(instancetype)rx_mapIntoCollection:(id<RXMutableCollection>)collection block:(RXCollectionMapBlock)block {
	return [self rx_foldInitialValue:collection block:^id(id<RXMutableCollection> memo, id each) {
		return [memo rx_append:block(each)];
	}];
}

-(instancetype)rx_mapWithBlock:(RXCollectionMapBlock)block {
	return [self rx_mapIntoCollection:[self.class rx_emptyMutableCollection] block:block];
}


-(instancetype)rx_filterIntoCollection:(id<RXMutableCollection>)collection block:(RXCollectionFilterBlock)block {
	return [self rx_mapIntoCollection:collection block:^id(id each) {
		return block(each)?
			each
		:	nil;
	}];
}

-(instancetype)rx_filterWithBlock:(RXCollectionFilterBlock)block {
	return [self rx_filterIntoCollection:[self.class rx_emptyMutableCollection] block:block];
}

@end


@implementation NSMutableArray (RXCollection)

-(instancetype)rx_append:(id)element {
	if (element)
		[self addObject:element];
	return self;
}

@end


@implementation NSSet (RXCollectionEmpty)

+(id<RXMutableCollection>)rx_emptyMutableCollection {
	return [NSMutableSet set];
}

@end

@implementation NSMutableSet (RXCollection)

-(instancetype)rx_append:(id)element {
	if (element)
		[self addObject:element];
	return self;
}

@end
