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

int run_language_server(const struct fd_ops *ops) {
    become_new_init_child();
    int pid = current_pid();
    generic_mknodat(AT_PWD, "/dev/tty8", S_IFCHR|0666, dev_make(TTY_CONSOLE_MAJOR, 8));
    create_one_stdio("/dev/tty8", 0, TTY_PSEUDO_SLAVE_MAJOR, 8);
    create_one_adhoc_fd_stdio(ops, 1);
    create_file("/var/log/clangd-stderr.txt");
    create_one_stdio("/var/log/clangd-stderr.txt", 2, TTY_PSEUDO_SLAVE_MAJOR, 8);
    clangd_tty_fd = generic_open("/dev/tty8", O_RDWR_, 0);
    do_execve("/usr/bin/clangd", 1, "/usr/bin/clangd\0", "");
    task_start(current);
    return pid;
}

void send_server(const char *data, int length) {
    tty_input(clangd_tty_fd->tty, data, length, false);
}
