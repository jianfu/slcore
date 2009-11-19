#include "blasbench.h"

BEGIN_VARS
DEF_COUNTER(n)
DEF_ARRAY_IN(sx)
DEF_COUNTER(incx)
DEF_SCALAR(nrm)
END_VARS

BEGIN_READ
READ_COUNTER(n)
READ_ARRAY_IN(sx, n)
READ_COUNTER(incx)
END_READ

BEGIN_PREPARE
END_PREPARE

BEGIN_WORK
     sl_create(,,,,,,,FUNCTION,
	       sl_shfarg(FLOAT, ret, 0.),
		 sl_glarg(long, , USE_VAR(n)),
		 sl_glarg(const FLOAT*, , USE_VAR(sx)),
	       sl_glarg(long, , USE_VAR(incx)));
sl_sync();
USE_VAR(nrm) = sl_geta(ret);
END_WORK

BEGIN_OUTPUT
PRINT_SCALAR(nrm)
END_OUTPUT

BEGIN_TEARDOWN
FREE_ARRAY_IN(sx)
END_TEARDOWN

BEGIN_DESC
BENCH_TITLE("BLAS: _NRM2")
BENCH_AUTHOR("kena")
BENCH_DESC("Compute SQRT(X[i]^2 + Y[i]^2)")
END_DESC
