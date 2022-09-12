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
  errno  = 0;
  result = lockf(NUM2INT(fd), NUM2INT(cmd), NUM2INT(len));
  if (result != 0) {
    err   = errno;
    errno = 0;
    rb_syserr_fail(err, "lockf");
  } else {
    return INT2NUM(result);
  }
}

void
Init_lockf(void)
{
  VALUE mLock, mFFI, mFile;

  mLock = rb_define_module("Lock");
  mFile = rb_const_get(mLock, rb_intern("File"));
  mFFI = rb_const_get(mFile, rb_intern("FFI"));
  rb_define_const(mFile, "F_LOCK", INT2NUM(F_LOCK));
  rb_define_const(mFile, "F_TLOCK", INT2NUM(F_TLOCK));
  rb_define_const(mFile, "F_ULOCK", INT2NUM(F_ULOCK));
  rb_define_const(mFile, "F_TEST", INT2NUM(F_TEST));
  rb_define_module_function(mFFI, "lockf", lockf_lock, 3);
}
