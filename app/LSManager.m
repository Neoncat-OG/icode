//
//  LSManager.m
//  iCode
//
//  Created by morinoyu8 on 06/24/23.
//

#import <Foundation/Foundation.h>
#import "LSManager.h"
#import "FileManager.h"

static struct fd *clangd_tty_fd;
static int clangdid;

int run_language_server(const struct fd_ops *x) {
    become_new_init_child();
    int pid = current_pid();
    generic_mknodat(AT_PWD, "/dev/tty8", S_IFCHR|0666, dev_make(TTY_CONSOLE_MAJOR, 8));
    create_file("/var/log/clangd-stdout.txt");
    create_file("/var/log/clangd-stderr.txt");
    create_one_stdio("/dev/tty8", 0, TTY_PSEUDO_SLAVE_MAJOR, 8);
    create_one_stdio("/var/log/clangd-stderr.txt", 2, TTY_PSEUDO_SLAVE_MAJOR, 8);
    struct fd *fd = adhoc_fd_create(x);
    current->files->files[1] = fd;
    clangd_tty_fd = generic_open("/dev/tty8", O_RDWR_, 0);
    do_execve("/usr/bin/clangd", 1, "/usr/bin/clangd\0", "");
    task_start(current);
    clangdid = 1;
    return pid;
}

void send_server(const char *data, int length) {
    tty_input(clangd_tty_fd->tty, data, length, false);
}
