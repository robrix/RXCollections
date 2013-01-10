//  RXCollectionArrayTests.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import "RXAssertions.h"
#import "RXCollection.h"

@interface RXCollectionTests : SenTestCase
@property (readonly) NSArray *fixture;
@end

@implementation RXCollectionTests

-(NSArray *)fixture {
	return @[@"Pixel", @"Kiwi", @"Maggie", @"Max"];
}


-(void)testMappingAppliesAFunctionToEachValueAndBuildsACollection {
	RXAssertEquals(RXMap(self.fixture, nil, ^id(id each) {
		return [@"Bandit:" stringByAppendingString:each];
	}), (@[@"Bandit:Pixel", @"Bandit:Kiwi", @"Bandit:Maggie", @"Bandit:Max"]));
}


-(void)testFilteringReturnsAnArrayIncludingObjectsForWhichTheBlockReturnsTrue {
	RXAssertEquals(RXFilter(self.fixture, nil, ^bool(id each) {
		return [each hasPrefix:@"M"];
	}), (@[@"Maggie", @"Max"]));
}


-(void)testFoldingWithAnInitialValueReturnsTheResultOfCallingTheBlockWithTheInitialOrPreviousResultAndEachElement {
	RXAssertEquals(RXFold(self.fixture, @"", ^id(id memo, id each) {
		return [memo stringByAppendingString:each];
	}), @"PixelKiwiMaggieMax");
}

-(void)testFoldingWithoutAnInitialValueReturnsTheResultOfCallingTheBlockWithNilOrThePreviousResultAndEachElement {
	RXAssertEquals(RXFold(self.fixture, nil, ^id(id memo, id each) {
		return [each stringByAppendingString:memo ?: @""];
	}), @"MaxMaggieKiwiPixel");
}


-(void)testDetectingReturnsTheFirstEncounteredObjectForWhichTheBlockReturnsTrue {
	RXAssertEquals(RXDetect(self.fixture, ^bool(id each) {
		return [each hasPrefix:@"M"];
	}), @"Maggie");
}


@end
