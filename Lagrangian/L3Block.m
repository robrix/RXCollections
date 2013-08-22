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

struct L3Block *L3BlockFromBlockObject(id block_object) {
	return (__bridge struct L3Block *)block_object;
}

const char *L3BlockGetSignature(id block_object) {
	struct L3Block *block = L3BlockFromBlockObject(block_object);
	
	NSCParameterAssert(block != nil);
	NSCParameterAssert(block->flags & BLOCK_HAS_SIGNATURE);
	NSCParameterAssert(block->descriptor != NULL);
	
	return block->flags & BLOCK_HAS_COPY_DISPOSE?
		block->descriptor->signature_for_copy_dispose
	:	block->descriptor->signature;
}
