#ifndef L3_BLOCK_H
#define L3_BLOCK_H

#import <Block.h>
#import <L3Defines.h>

L3_EXTERN const char *L3BlockGetSignature(id block);

typedef void (*L3BlockFunction)(void *, ...);
L3_EXTERN L3BlockFunction L3BlockGetFunction(id block);

#endif // L3_BLOCK_H
