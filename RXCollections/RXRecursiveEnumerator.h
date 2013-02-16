//  RXRecursiveEnumerator.h
//  Created by Rob Rix on 2013-01-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

/**
 RXRecursiveEnumerator
 
 Provides NSFastEnumeration (and thus for (… in …) support) for trees whose children are provided under a KVC-compliant selector.
 
 For example:
 
	NSView *view = …; // assumed to exist
	for (NSView *view in [RXRecursiveEnumerator enumeratorWithTarget:view keyPath:@"subviews"]) { … }
 
 This enumeration is all-inclusive—the root and all branches are mapped as well as any leaves. Heterogeneous branch/leaf trees (i.e. where leaves are not simply branches with zero children) are supported so long as the branches respond to the selector represented by keyPath and the leaves do not (or return an empty collection for that key path).
 */

@interface RXRecursiveEnumerator : NSObject <RXTraversal>

+(instancetype)enumeratorWithTarget:(id)target keyPath:(NSString *)keyPath;

@property (nonatomic, strong, readonly) id target;
@property (nonatomic, copy, readonly) NSString *keyPath;

@end
