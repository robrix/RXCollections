#ifndef L3_BLOCK_H
#define L3_BLOCK_H

#if __has_feature(modules)
@import Darwin.block;
#else
#import <Block.h>
#endif

#import <L3Defines.h>

L3_EXTERN const char *L3BlockGetSignature(id block_object);

#endif // L3_BLOCK_H
