#include "mem.h"
#include <string.h>

void *xmemcpy(void *__restrict dst, const void *__restrict src, size_t n) {
    return memcpy(dst, src, n);
}
