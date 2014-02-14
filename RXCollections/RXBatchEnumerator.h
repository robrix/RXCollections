//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerator.h>

/**
 An enumeration which produces its objects in batches.
 */
@interface RXBatchEnumerator : NSEnumerator <RXEnumerator>

+(NSUInteger)defaultCapacity;

/**
 Subclass responsibility. Produces a batch of objects and returns the number of objects produced.
 
 \param batch A batch to write produced objects into.
 \param count The maximum number of objects that can be written into \c batch.
 \return The number of objects produced. A return value of 0 indicates that the enumeration has completed.
 */
-(NSUInteger)countOfObjectsProducedInBatch:(id __strong [])batch count:(NSUInteger)count;

@end
