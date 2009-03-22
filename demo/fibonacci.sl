//                                                             -*- m4 -*-
// fibonacci.sl: this file is part of the slc project.
//
// Copyright (C) 2009 The SL project.
// All rights reserved.
//
// $Id$
//
m4_include(svp/iomacros.slh)

m4_define(INT, unsigned long long)

sl_def(fibo_compute, void,
       sl_shparm(INT, prev), sl_shparm(INT, prev2), sl_glparm(INT*, fibo))
{
  sl_index(i);

  INT n = sl_getp(prev) + sl_getp(prev2);
  sl_setp(prev2, sl_getp(prev));
  sl_setp(prev, n);
  sl_getp(fibo)[i] = n;
}
sl_enddef

sl_def(fibo_print, void,
       sl_shparm(INT, guard), sl_glparm(INT*, fibo))
{
  sl_index(i);

  INT p1 = sl_getp(fibo)[i - 2];
  INT p2 = sl_getp(fibo)[i - 1];
  INT p3 = sl_getp(fibo)[i];

  INT n = sl_getp(guard);
  printf("The %uth Fibonacci number is %u + %u = %u\n", (INT)i, p1, p2, p3);
  sl_setp(guard, n);
}
sl_enddef

m4_define(N, 15)
INT fibonums[N];

sl_def(t_main, void)
{
  // first, compute the numbers.
  fibonums[0] = fibonums[1] = 1;
  sl_create(,,2,N,,,,
	    fibo_compute,
	    sl_sharg(INT, prev, 1),
	    sl_sharg(INT, prev2, 1),
	    sl_glarg(INT*, fibo, fibonums));
  sl_sync();

  // then, print them.
  sl_create(,,2,N,,,,
	    fibo_print,
	    sl_sharg(INT, guard, 0), sl_glarg(INT*, t, fibonums));
  sl_sync();

}
sl_enddef