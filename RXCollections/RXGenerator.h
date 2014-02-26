//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerator.h>

@class RXGenerator;

typedef id (^RXGeneratorBlock)(RXGenerator *generator);

@interface RXGenerator : RXEnumerator <RXEnumerator>

-(instancetype)initWithBlock:(RXGeneratorBlock)block;

@end
