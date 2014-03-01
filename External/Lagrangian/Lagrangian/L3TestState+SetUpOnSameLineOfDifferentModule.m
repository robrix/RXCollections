#import "L3TestState.h"
#import "Lagrangian.h"
#import <objc/runtime.h>

l3_setup(L3TestState_SetUpOnSameLineOfDifferentModule, (NSUInteger line, int _)) { self.state.line = __LINE__; }

l3_test(@selector(line)) {
	l3_expect(self.state.line).to.equal(@5);
}
