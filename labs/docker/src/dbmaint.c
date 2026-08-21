/*
 * Intentionally vulnerable SUID helper for local OSCP-prep lab "catalog".
 * Calls a relative command so PATH can be hijacked. Training use only.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void) {
    if (setuid(0) != 0) {
        perror("setuid");
        return 1;
    }
    setgid(0);
    return system("dbdump");
}
