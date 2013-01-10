//  RXCollectionObjectTests.m
//  Created by Rob Rix on 2013-01-10.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXAssertions.h"
#import "RXCollection.h"

@interface RXCollectionObjectTests : SenTestCase
@end

@implementation RXCollectionObjectTests

-(void)testObjectFastEnumeration {
	NSMutableArray *enumerated = [NSMutableArray new];
	id subject = [NSObject new];
	for (id object in subject) {
		[enumerated addObject:object];
	}
	RXAssertEquals(enumerated, @[subject]);
}

@end
