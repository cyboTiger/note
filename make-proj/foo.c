#include "foo.h"
#include "bar.h"

int main() {
    int x = add(1, 2) + sub(5, 4);
    printf("x = %d", x);
}

int add(int a, int b) {
    return a + b;
}