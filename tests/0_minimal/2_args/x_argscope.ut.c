// m4_include(proto.m4)
#include <libutc.h>

ut_def(foo, void, ut_glparm(int, a)) {} ut_enddef

// XFAIL: C (use of arg out of scope)
ut_def(t_main, void)
{
  {
    ut_create(f,,,,,,, foo, ut_glarg(int, a, 10));
    ut_sync(f);
  }
  int z = ut_geta(a);
}
ut_enddef