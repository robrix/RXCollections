//  RXCollection.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXCollection.h"

@implementation NSObject (RXCollection)

-(id)rx_foldInitialValue:(id)initial withBlock:(RXCollectionFoldBlock)block {
	for(id each in (id<NSFastEnumeration>)self) {
		initial = block(initial, each);
	}
	return initial;
}

-(id)rx_foldWithBlock:(RXCollectionFoldBlock)block {
	return [self rx_foldInitialValue:nil withBlock:block];
}


-(id)rx_detectWithBlock:(RXCollectionFilterBlock)block {
	for(id each in (id<NSFastEnumeration>)self) {
		if(block(each)) {
			return each;
		}
	}
	return nil;
}

@end


@implementation NSArray (RXCollection)

+(NSArray *)rx_arrayByMappingCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionMapBlock)block {
	NSMutableArray *array = [NSMutableArray array];
	for(id each in collection) {
		id result = block(each);
		if(result != nil)
			[array addObject:result];
	}
	return array;
}

+(NSArray *)rx_arrayByFilteringCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionFilterBlock)block {
	NSMutableArray *array = [NSMutableArray array];
	for(id each in collection) {
		if(block(each)) {
			[array addObject:each];
		}
	}
	return array;
}

@end


@implementation NSSet (RXCollection)

+(NSSet *)rx_setByMappingCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionMapBlock)block {
	NSMutableSet *set = [NSMutableSet set];
	for(id each in collection) {
		id result = block(each);
		if(result != nil)
			[set addObject:set];
	}
	return set;
}

+(NSSet *)rx_setByFilteringCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionFilterBlock)block {
	NSMutableSet *set = [NSMutableSet set];
	for(id each in collection) {
		if(block(each)) {
			[set addObject:each];
		}
	}
	return set;
}

@end
