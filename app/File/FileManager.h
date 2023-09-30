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

#define MAX_CONTENTS 65536

struct filecontent {
    char *name;
    int kind;
};

ssize_t read_file(const char *path, char *buf, size_t size);
ssize_t write_file(const char *path, const char *buf, size_t size);
ssize_t create_file(const char *path);
int create_directory(const char *path);
int get_file_list(const char *path, struct filecontent *contents);
char *get_all_path(const char *path);
