//  L3Assertions.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"

#define l3_assert(object, pattern) \
	[testCase assertThat:l3_to_object(object) matches:pattern]

#define l3_isNotNil() \
	(^bool(id x){ return x != nil; })
