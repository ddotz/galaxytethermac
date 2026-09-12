#ifndef NETWORK_POLICY_H
#define NETWORK_POLICY_H
#include <stddef.h>
/* 1: other physical connection, 0: none, -1: cannot determine safely. */
int network_other_connected(char *interface_name, size_t capacity);
#endif
