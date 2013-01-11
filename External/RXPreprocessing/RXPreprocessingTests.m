// clang -fmacro-backtrace-limit=0 -framework Foundation -o RXPreprocessingTests RXPreprocessingTests.m && ./RXPreprocessingTests && rm ./RXPreprocessingTests

#import <Foundation/Foundation.h>
#import "RXInterpolation.h"

int main(int argc, const char *argv[]) {
	@autoreleasepool {
		RXLog(@"look! I can log things!\n", @[@"Things like this!\n"][0], "And things like this too!");
	}
	return 0;
}
