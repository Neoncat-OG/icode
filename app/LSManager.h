//
//  LSManager.h
//  iCode
//
//  Created by morinoyu8 on 06/24/23.
//

#include "kernel/calls.h"
#include "kernel/task.h"
#include "kernel/init.h"
#include "fs/devices.h"

int run_language_server(const struct fd_ops *x);
void send_server(const char *data, int length);
