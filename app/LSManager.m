//
//  LSManager.m
//  iCode
//
//  Created by morinoyu8 on 06/24/23.
//

#import <Foundation/Foundation.h>
#import "LSManager.h"
#import "FileManager.h"

int run_language_server(void) {
    become_new_init_child();
    int pid = current_pid();
    generic_mknodat(AT_PWD, "/dev/tty8", S_IFCHR|0666, dev_make(4, 8));
    char *stdioFile = "/dev/tty8";
    create_stdio(stdioFile, 136, 0);
    printf("clangd pid: %d\n", pid);
    do_execve("/usr/bin/clangd", 1, "/usr/bin/clangd\0", "");
    // create_piped_stdio();
    task_start(current);
    
    
    
    // printf("%d\n", x);
//    printf("Hello Clang, pid = %d\n", pid);
//    //FILE *f = fopen("",     )
//    //fprintf(, "Content-Length: 47\r\n{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialized\"}");
//
//    // Content-Length: 47
//    // {"jsonrpc":"2.0","id":1,"method":"initialized"}
//    write_file("/dev/pts/0", "Content-Length: 47\r\n{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialized\"}\n\0", 68);
//
//
//    char buf[1000];
//    char name[100];
//    sprintf(name, "/proc/%d/fd/1", pid);
//    read_file(name, buf, 1000);
//    printf("%s\n", buf);
    // printf("%d\n", pid_get_task(pid)->files->files[0]->tty->num);
    // printf("%d\n", pid_get_task(pid)->files->files[0]->refcount);
    return pid;
}

void run(int pid) {
    char buf[10];
    char name[100];
    sprintf(name, "/proc/%d/fd/0", pid);
    ssize_t x = write_file(name, "Hello", 10);
    // printf("%s: %zd\n%s\n", name, x, buf);
}
