#ifndef L3_BLOCK_H
#define L3_BLOCK_H

#if __has_feature(modules)
@import Darwin.block;
#else
#import <Block.h>
#endif

#import <L3Defines.h>

L3_EXTERN const char *L3BlockGetSignature(id block);

typedef void (*L3BlockFunction)(void *, ...);
L3_EXTERN L3BlockFunction L3BlockGetFunction(id block);

#endif // L3_BLOCK_H
