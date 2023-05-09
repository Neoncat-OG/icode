//
//  FileManager.m
//  iCode
//
//  Created by morinoyu8 on 05/09/23.
//

#import "FileManager.h"

static ssize_t read_file(const char *path, char *buf, size_t size) {
    struct fd *fd = generic_open(path, O_RDONLY_, 0);
    if (IS_ERR(fd))
        return PTR_ERR(fd);
    ssize_t n = fd->ops->read(fd, buf, size);
    fd_close(fd);
    if (n == size)
        return _ENAMETOOLONG;
    return n;
}

static ssize_t write_file(const char *path, const char *buf, size_t size) {
    struct fd *fd = generic_open(path, O_WRONLY_|O_CREAT_|O_TRUNC_, 0644);
    if (IS_ERR(fd))
        return PTR_ERR(fd);
    ssize_t n = fd->ops->write(fd, buf, size);
    fd_close(fd);
    return n;
}

static int remove_directory(const char *path) {
    return generic_rmdirat(AT_PWD, path);
}

ssize_t create_file(const char *path) {
    ssize_t res = write_file(path, "", 0);
    return res;
}
