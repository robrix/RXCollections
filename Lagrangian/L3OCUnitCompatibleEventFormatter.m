//  L3OCUnitCompatibleEventFormatter.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3OCUnitCompatibleEventFormatter.h"
#import "L3Event.h"
#import "L3EventSource.h"
#import "Lagrangian.h"

@interface L3OCUnitCompatibleEventFormatter () <L3EventVisitor>
@end

@implementation L3OCUnitCompatibleEventFormatter

@l3_suite("OCUnit-compatible event formatters");

-(NSString *)formatEvent:(L3Event *)event {
	return [event acceptVisitor:self];
}


-(NSString *)unknownEvent:(L3Event *)event {
	return nil;
}


@l3_test("format test case started events compatibly with OCUnit") {
	NSString *string = [[L3OCUnitCompatibleEventFormatter new] formatEvent:[L3Event eventWithState:L3EventStateStarted source:_case]];
	assert(l3_assert(string, l3_not(nil)));
}

-(NSString *)startedEvent:(L3Event *)event {
	NSString *result = nil;
	if ([event.source isKindOfClass:[L3TestCase class]]) {
		result = [NSString stringWithFormat:@"Test Case '-[%@]' started.", event.source.name];
	} else if ([event.source isKindOfClass:[L3TestSuite class]]) {
		result = [NSString stringWithFormat:@"Test Suite '%@' started at %@", event.source.name, event.date];
	}
	return result;
}

-(NSString *)endedEvent:(L3Event *)event {
	NSString *result = nil;
	if ([event.source isKindOfClass:[L3TestCase class]]) {
		result = [NSString stringWithFormat:@"Test Case '-[%@]' %@ (%.3f seconds).", event.source.name, @"passed", 0.0f];
	} else if ([event.source isKindOfClass:[L3TestSuite class]]) {
		result = [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\nExecuted %u tests, with %u failures (%u unexpected) in %.3f (%.3f) seconds", event.source.name, event.date, 0u, 0u, 0u, 0.0f, 0.0f];
	}
	return result;
}


-(NSString *)succeededEvent:(L3Event *)event {
	return nil;
}

-(NSString *)failedEvent:(L3Event *)event {
	return @"fail!!";
}

@end
