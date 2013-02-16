//  RXMappingTraversal.h
//  Created by Rob Rix on 2013-02-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

// not thread safe for NSFastEnumeration. just don't.

/**
 RXMappingTraversal
 
 Given an NSFastEnumeration-compliant collection or other enumeration, RXMappingTraversal provides a traversal (and therefore for(in) support) which maps the traversed objects using the supplied block.
 
 This is intended to be used via its opaque interface, RXLazyMap.
 
 The block which maps individual objects can safely return nil.
 */

@interface RXMappingTraversal : NSObject <RXTraversal>

+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration block:(id(^)(id))block;

@property (nonatomic, strong, readonly) id<NSFastEnumeration> enumeration;
@property (nonatomic, copy, readonly) id(^block)(id);

@end
