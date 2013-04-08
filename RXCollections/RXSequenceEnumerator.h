//  RXSequenceEnumerator.h
//  Created by Rob Rix on 2013-03-31.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXFilter.h>
#import <RXCollections/RXMap.h>
#import <RXCollections/RXSequence.h>

@interface RXSequenceEnumerator : NSObject <RXSequence>

+(instancetype)enumeratorWithSequence:(id<RXSequence>)sequence filterBlock:(RXFilterBlock)filterBlock mapBlock:(RXMapBlock)mapBlock;

@property (nonatomic, strong, readonly) id<RXSequence> sequence;
@property (nonatomic, copy, readonly) RXFilterBlock filterBlock;
@property (nonatomic, copy, readonly) RXMapBlock mapBlock;

@end
