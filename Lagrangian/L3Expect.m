//  L3Expect.m
//  Created by Rob Rix on 7/25/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "L3Expect.h"
#import "L3Test.h"

@interface L3Expectation ()

@property (nonatomic, strong) L3Expectation *child;

@end

@implementation L3Expectation

-(instancetype)initWithSubject:(id)subject identifier:(id)identifier parent:(L3Expectation *)parent predicate:(NSPredicate *)predicate {
	if ((self = [super init])) {
		_subject = subject;
		_identifier = identifier;
		_parent = parent;
		_predicate = predicate ? predicate : [NSPredicate predicateWithFormat:@"childValue == YES"];
	}
	return self;
}


-(L3Expectation *)to {
	return self;
}

-(L3Expectation *)not {
	return self.child = [[L3Expectation alloc] initWithSubject:self.subject identifier:nil parent:self predicate:[NSPredicate predicateWithFormat:@"childValue == NO"]];
}

-(L3Expectation *(^)(id))equal {
	return ^(id object){
		return self.child = [[L3Expectation alloc] initWithSubject:self.subject identifier:nil parent:self predicate:[NSPredicate predicateWithFormat:@"subject == %@", object]];
	};
}


-(bool)wasMet {
	bool childValue = [self.child wasMet];
	return [self.predicate evaluateWithObject:self.subject substitutionVariables:@{@"subject": self.subject, @"expectation": self, @"childValue": @(childValue) }];
}

@end


L3Expectation *L3Expect(L3Test *test, int identifier, id subject) {
	L3Expectation *expectation = [[L3Expectation alloc] initWithSubject:subject identifier:@(identifier) parent:nil predicate:nil];
	[test addExpectation:expectation];
	return expectation;
}
