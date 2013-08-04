#ifndef __rx_test__
#define __rx_test__ 1

#if __has_feature(c_static_assert) || __has_extension(c_static_assert)

#define rx_static_test(...) _rx_static_test(__VA_ARGS__)
#define _rx_static_test(...) _Static_assert(__VA_ARGS__, "" #__VA_ARGS__)

rx_static_test(1 == 1);

#else
#define rx_static_test(...)
#endif

#endif // __rx_test__
