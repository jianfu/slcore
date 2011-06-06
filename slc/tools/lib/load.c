//
// load.c: this file is part of the SL toolchain.
//
// Copyright (C) 2009,2010 The SL project.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 3
// of the License, or (at your option) any later version.
//
// The complete GNU General Public Licence Notice can be found as the
// `COPYING' file in the root directory.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

static 
void fail(const char *where)
{
    fprintf(stderr, "load: ");
    perror(where);
    exit(1);
}

static
void load_binary_data(const char* fname, void**ptr, bool verbose)
{
    FILE *f;

    *ptr = 0;

    if (!fname) {
        fprintf(stderr, "load: warning: no data file specified (did you use slr?)\n");
        return ;
    }
    if (verbose) fprintf(stderr, "# load: loading data from %s...\n", fname);

#define ensure(Cond, What) do { if (!(Cond)) fail(What); } while(0);

    ensure(f = fopen(fname, "rb"), "fopen");

    ensure(fseek(f, 0L, SEEK_END) == 0, "fseek");
    
    long sz = ftell(f);
    ensure(sz >= 0, "ftell");
    
    if (sz > 0) {
        void *p;
        long alloc_sz = sz + sizeof(double); // ensure enough space after end

#ifdef HAVE_POSIX_MEMALIGN
        ensure(posix_memalign(&p, 64, alloc_sz) == 0 && p != NULL, "posix_memalign");
#else
        // align manually
        ensure(p = malloc(alloc_sz + 64), "malloc");
        if ((uintptr_t)p % 64 != 0)
            p = (char*)p + (64 - (uintptr_t)p % 64);
#endif
        
        fseek(f, 0L, SEEK_SET);
        ensure(fread(p, sz, 1, f) == 1, "fread");
        *ptr = p;
        if (verbose) fprintf(stderr, "# load: %ld bytes loaded at %p\n", sz, p);
    }
    fclose(f);
}


#ifdef __cplusplus
extern "C" {
#endif

void *__slr_base = 0;
void *__fibre_base = 0;

__attribute__((__constructor__))
void slr_init(void)
{
    char *vs = getenv("VERBOSE");
    bool verbose = false;
    if (vs && vs[0])
        verbose = true;
    
    char *data = getenv("SLR_DATA");
    if (data)
        load_binary_data(data, &__slr_base, verbose);

    char *fdata = getenv("SLR_FDATA");
    if (fdata)
        load_binary_data(fdata, &__fibre_base, verbose);    
}

#ifdef __cplusplus
}
#endif
