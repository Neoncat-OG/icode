//
//  FileManager.h
//  iCode
//
//  Created by morinoyu8 on 05/09/23.
//

#include "kernel/calls.h"
#include "fs/path.h"

#ifdef ISH_LINUX
#import "LinuxInterop.h"
#endif

ssize_t create_file(const char *path);
int create_directory(const char *path);
