//  L3StringInflections.m
//  Created by Rob Rix on 2012-11-14.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3StringInflections.h"
#import "Lagrangian.h"

@implementation L3StringInflections

@l3_suite("string inflections");


@l3_test("pluralize nouns when their cardinality is 0") {
	l3_assert([L3StringInflections pluralizeNoun:@"dog" count:0], l3_is(@"dogs"));
}

@l3_test("do not pluralize nouns when their cardinality is 1") {
	l3_assert([L3StringInflections pluralizeNoun:@"cat" count:1], l3_is(@"cat"));
}

@l3_test("pluralize nouns when their cardinality is 2 or greater") {
	l3_assert([L3StringInflections pluralizeNoun:@"bird" count:2], l3_is(@"birds"));
}

+(NSString *)pluralizeNoun:(NSString *)noun count:(NSUInteger)count {
	return count == 1?
		noun
	:	[noun stringByAppendingString:@"s"];
}


@l3_test("cardinalize nouns with their plurals when cardinality is not 1") {
	l3_assert([L3StringInflections cardinalizeNoun:@"plural" count:0], @"0 plurals");
	l3_assert([L3StringInflections cardinalizeNoun:@"cardinal" count:1], @"1 cardinal");
	l3_assert([L3StringInflections cardinalizeNoun:@"ordinal" count:2], @"2 ordinals");
}

+(NSString *)cardinalizeNoun:(NSString *)noun count:(NSUInteger)count {
	return [NSString stringWithFormat:@"%lu %@", (unsigned long)count, [self pluralizeNoun:noun count:count]];
}

@end
