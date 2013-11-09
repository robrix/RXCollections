#import "L3Block.h"

typedef enum : int {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
} L3BlockFlags;

struct L3Block {
	void *isa;
	int flags;
	int reserved;
	void (*invoke)(void *, ...);
	struct block_descriptor_s {
		unsigned long int reserved;
		unsigned long int size;
		union {
			struct {
				void (*copy)(void *destination, void *source);
				void (*dispose)(void *source);
				const char *signature_for_copy_dispose;
			};
			const char *signature;
		};
	} *descriptor;
};

struct L3Block *L3BlockFromBlockObject(id block) {
	return (__bridge struct L3Block *)block;
}

const char *L3BlockGetSignature(id block) {
	struct L3Block *blockStructure = L3BlockFromBlockObject(block);
	
	NSCParameterAssert(blockStructure != nil);
	NSCParameterAssert(blockStructure->flags & BLOCK_HAS_SIGNATURE);
	NSCParameterAssert(blockStructure->descriptor != NULL);
	
	return blockStructure->flags & BLOCK_HAS_COPY_DISPOSE?
		blockStructure->descriptor->signature_for_copy_dispose
	:	blockStructure->descriptor->signature;
}

L3BlockFunction L3BlockGetFunction(id block) {
	return L3BlockFromBlockObject(block)->invoke;
}
