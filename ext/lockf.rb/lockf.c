#include <ruby.h>
#include <unistd.h>
#include <errno.h>
#include "lockf.h"

static VALUE
lockf_lock(VALUE self, VALUE fd, VALUE cmd, VALUE len)
{
  int result, err;

  Check_Type(fd, T_FIXNUM);
  Check_Type(cmd, T_FIXNUM);
  Check_Type(len, T_FIXNUM);
  errno = 0;
  result = lockf(NUM2INT(fd), NUM2INT(cmd), NUM2INT(len));
  if (result != 0) {
    err = errno;
    errno = 0;
    rb_syserr_fail(err, "lockf");
  } else {
    return INT2NUM(result);
  }
}

void
Init_lockf(void)
{
  VALUE cLockf;

  cLockf = rb_define_class("LockFile", rb_cObject);
  rb_define_const(cLockf, "F_LOCK", INT2NUM(F_LOCK));
  rb_define_const(cLockf, "F_TLOCK", INT2NUM(F_TLOCK));
  rb_define_const(cLockf, "F_ULOCK", INT2NUM(F_ULOCK));
  rb_define_const(cLockf, "F_TEST", INT2NUM(F_TEST));
  rb_define_singleton_method(cLockf, "lockf", lockf_lock, 3);
}
