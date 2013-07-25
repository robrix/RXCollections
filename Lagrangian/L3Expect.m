//  L3Expect.m
//  Created by Rob Rix on 7/25/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "L3Expect.h"
#import "L3Test.h"

@interface L3Expectation ()

@property (nonatomic, readonly) NSPredicate *predicate;
@property (nonatomic, weak, readonly) L3Expectation *parent;
@property (nonatomic, strong) L3Expectation *child;

@end

@implementation L3Expectation

-(instancetype)initWithSubject:(id)subject parent:(L3Expectation *)parent predicate:(NSPredicate *)predicate {
	if ((self = [super init])) {
		_subject = subject;
		_parent = parent;
		_predicate = predicate ? predicate : [NSPredicate predicateWithFormat:@"childValue == YES"];
	}
	return self;
}


-(L3Expectation *)to {
	return self;
}

-(L3Expectation *)not {
	return self.child = [[L3Expectation alloc] initWithSubject:self.subject parent:self predicate:[NSPredicate predicateWithFormat:@"childValue == NO"]];
}

-(L3Expectation *(^)(id))equal {
	return ^(id object){
		return self.child = [[L3Expectation alloc] initWithSubject:self.subject parent:self predicate:[NSPredicate predicateWithFormat:@"subject == %@", object]];
	};
}


-(bool)valueWithSubject:(id)subject {
	bool childValue = [self.child valueWithSubject:subject];
	return [self.predicate evaluateWithObject:subject substitutionVariables:@{@"subject": subject, @"expectation": self, @"childValue": @(childValue) }];
}

@end


L3Expectation *L3Expect(L3Test *test, int identifier, id subject) {
	L3Expectation *expectation = [[L3Expectation alloc] initWithSubject:subject parent:nil predicate:nil];
	[test addExpectation:expectation forIdentifier:@(identifier)];
	return expectation;
}
