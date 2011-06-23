########### MT-Alpha components ###########

MTALIB_CSRC = \
	src/mtinput.c \
	src/abort.c \
	src/atoi.c \
	src/atol.c \
	src/atoll.c \
	src/bcopy.c \
	src/bzero.c \
	src/ctype.c \
	src/dtoa_simple.c \
	src/errno.c \
	src/exit.c \
	src/ffs.c \
	src/fprintf.c \
	src/fputc.c \
	src/fputs.c \
	src/fwrite.c \
	src/getenv.c \
	src/_hdtoa.c \
	src/heap.c \
	src/malloc.c \
	src/memcpy.c \
	src/memmove.c \
	src/memset.c \
	src/mtstdio.c \
	src/perf.c \
	src/perf_wrappers.c \
	src/printf.c \
	src/printf-pos.c \
	src/putc.c \
	src/putchar.c \
	src/puts.c \
	src/snprintf.c \
	src/sprintf.c \
	src/stpcpy.c \
	src/stpncpy.c \
	src/strcat.c \
	src/strchr.c \
	src/strcmp.c \
	src/strcpy.c \
	src/strdup.c \
	src/strerror.c \
	src/strlcat.c \
	src/strlcpy.c \
	src/strlen.c \
	src/strncat.c \
	src/strncmp.c \
	src/strncpy.c \
	src/strnlen.c \
	src/strtol.c \
	src/strtoll.c \
	src/strtoul.c \
	src/strtoull.c \
	src/sys_errlist.c \
	src/tlstack_malloc.c \
	src/vprintf.c \
	src/vsnprintf.c

MTALIB_SRC = \
	src/time.c \
	src/malloc_excl.c \
	src/vfprintf.c \
	src/div.c \
	src/roman.c \
	src/io.c

MTALIB_SIM_SRC = \
	src/mtconf.c \
	src/mtargs.c \
	src/mtinit.c \
	src/mtgfx.c \
	src/mtsep.c

MTALIB_EXTRA = \
	src/floatio.h \
	src/fpmath.h \
	src/heap.h \
	src/malloc_wrappers.c \
	src/mgsim.h \
	src/missing_uclibc_math.c \
	src/mtconf.h \
	src/mtstdio.h \
	src/printfcommon.h \
	src/printflocal.h

EXTRA_DIST += $(MTALIB_CSRC) $(MTALIB_SRC) $(MTALIB_SIM_SRC) $(MTALIB_EXTRA)

MALLOC_DEFS = -DLACKS_SYS_TYPES_H \
	-DUSE_DL_PREFIX \
	-DHAVE_MMAP=0 \
	-DMORECORE_CANNOT_TRIM \
	-DMALLOC_FAILURE_ACTION="" \
	-DLACKS_UNISTD_H \
	-DUSE_BUILTIN_FFS=1 \
	-DLACKS_SYS_PARAM_H \
	-DLACKS_TIME

TLSMALLOC_DEFS = \
	-DNDEBUG \
	-Dtls_malloc=malloc \
	-Dtls_free=free \
	-Dtls_realloc=realloc \
	-Dtls_calloc=calloc

include $(srcdir)/gdtoa.mk

include $(srcdir)/src/mtamathobjs.mk
EXTRA_DIST += $(MTAMATHOBJS)

if ENABLE_SLC_MTALPHA

nobase_dist_pkgdata_DATA += \
	mtalpha-sim/include/sys/types.h \
	mtalpha-sim/include/bits/float.h \
	mtalpha-sim/include/alloca.h \
	mtalpha-sim/include/assert.h \
	mtalpha-sim/include/ctype.h \
	mtalpha-sim/include/errno.h \
	mtalpha-sim/include/float.h \
	mtalpha-sim/include/limits.h \
	mtalpha-sim/include/math.h \
	mtalpha-sim/include/stdbool.h \
	mtalpha-sim/include/stdarg.h \
	mtalpha-sim/include/stddef.h \
	mtalpha-sim/include/stdint.h \
	mtalpha-sim/include/stdio.h \
	mtalpha-sim/include/stdlib.h \
	mtalpha-sim/include/string.h \
	mtalpha-sim/include/strings.h \
	mtalpha-sim/include/time.h 

SHUTUP = \
	-Dshutup_cstring_h \
	-Dshutup_cstdlib_h \
	-Dshutup_cstdio_h \
	-Dshutup_cstrings_h \
	-Dshutup_ctime_h

MALLOC_DEFS_MTA = \
	-DPAGESIZE=0x40000000U

TLSMALLOC_DEFS_MTA = \
	-DARCH_TLS_SERVICES=\"tls_arch_mtalpha.h\" 

MTALIB_COBJS = \
	$(addprefix mta_,$(addsuffix .o,$(notdir $(basename $(MTALIB_CSRC))))) \
	$(addprefix mta_gdtoa_,$(addsuffix .o,$(notdir $(basename $(GDTOA_CSRC))))) \
	mta_tlsmalloc.o \
	mta_malloc_excl.o

SLC_MTA = $(SLC_RUN) -b mta $(SHUTUP)

mta_%.o: $(srcdir)/src/%.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $<

mta_gdtoa_%.o: $(srcdir)/src/gdtoa/%.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $<



mta_tlsmalloc_fast.o: $(srcdir)/src/tlsmalloc/tlsmalloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(TLSMALLOC_DEFS) $(TLSMALLOC_DEFS_MTA) -DNDEBUG

mta_tlsmalloc.o: $(srcdir)/src/tlsmalloc/tlsmalloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(TLSMALLOC_DEFS) $(TLSMALLOC_DEFS_MTA) -DFOOTERS

mta_tlsmalloc_debug.o: $(srcdir)/src/tlsmalloc/tlsmalloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(TLSMALLOC_DEFS) $(TLSMALLOC_DEFS_MTA) -DDEBUG_MALLOC -DFOOTERS

mta_tlsmalloc_mgdebug.o: $(srcdir)/src/tlsmalloc/tlsmalloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(TLSMALLOC_DEFS) $(TLSMALLOC_DEFS_MTA) -DDEBUG_MGSIM -DFOOTERS


mta_tlsmalloc_fast_nogc.o: $(srcdir)/src/tlsmalloc/tlsmalloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(TLSMALLOC_DEFS) $(TLSMALLOC_DEFS_MTA) -DNDEBUG -DDISABLE_GC

mta_tlsmalloc_nogc.o: $(srcdir)/src/tlsmalloc/tlsmalloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(TLSMALLOC_DEFS) $(TLSMALLOC_DEFS_MTA) -DFOOTERS -DDISABLE_GC

mta_tlsmalloc_nogc_debug.o: $(srcdir)/src/tlsmalloc/tlsmalloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(TLSMALLOC_DEFS) $(TLSMALLOC_DEFS_MTA) -DDEBUG_MALLOC -DFOOTERS -DDISABLE_GC

mta_tlsmalloc_nogc_mgdebug.o: $(srcdir)/src/tlsmalloc/tlsmalloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(TLSMALLOC_DEFS) $(TLSMALLOC_DEFS_MTA) -DDEBUG_MGSIM -DFOOTERS -DDISABLE_GC



mta_tlstack_malloc_mgdebug.o: $(srcdir)/src/tlstack_malloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< -DDEBUG_MGSIM


mta_malloc.o: $(srcdir)/src/malloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(MALLOC_DEFS) $(MALLOC_DEFS_MTA)

mta_malloc_debug.o: $(srcdir)/src/malloc.c
	$(slc_verbose)$(SLC_MTA) -c -o $@ $< $(MALLOC_DEFS) $(MALLOC_DEFS_MTA) -DDEBUG=1 -DABORT_ON_ASSERT_FAILURE=0 -DFOOTERS=1

# install the debug objects with other package data
pkglib_DATA += \
	mta_tlsmalloc_fast.o \
	mta_tlsmalloc_debug.o \
	mta_tlsmalloc_mgdebug.o \
	mta_tlsmalloc_fast_nogc.o \
	mta_tlsmalloc_nogc.o \
	mta_tlsmalloc_nogc_debug.o \
	mta_tlsmalloc_nogc_mgdebug.o \
	mta_tlstack_malloc_mgdebug.o \
	mta_malloc_debug.o

### Common rules ###

# define MTA_TEMPLATE

# # # arg 1 = slc target
# # # arg 2 = libdir
# # # arg 3 = libdir_undescores

# nobase_pkglib_DATA += \
#    $(2)/libm.a \
#    $(2)/libsl.a

# $(3)_libsl_a_CONTENTS = \
#	$(MTALIB_COBJS) \
#	$(addprefix $(2)/gdtoa_,$(addsuffix .o,$(notdir $(basename $(GDTOA_SRC))))) \
# 	$(addprefix $(2)/,$(addsuffix .o,$(notdir $(basename $(MTALIB_SRC))))) \
# 	$(addprefix $(2)/,$(addsuffix .o,$(notdir $(basename $(MTALIB_SIM_SRC))))) 

# CLEANFILES += \
# 	$($(3)_libsl_a_CONTENTS) \
# 	$(2)/libsl.a

# $(3)_libm_a_CONTENTS = \
# 	$(MTAMATHOBJS) \
# 	$(2)/missing_uclibc_math.o

# CLEANFILES += \
# 	$(2)/missing_uclibc_math.o \
# 	$(2)/libm.a

# SLC_CMD = $(SLC_RUN) -b $(1) $(SHUTUP)

# $(2)/%.o: $(srcdir)/src/%.c
# 	$(AM_V_at)$(MKDIR_P) $(2)
# 	$(slc_verbose)$(SLC_CMD) -c -o $@ $<

# $(2)/%.a:
#	$(AM_V_at)rm -f $@
#	$(AM_V_AR)$(AR_MTALPHA) cru $@ $^
#	$(AM_V_at)$(RANLIB_MTALPHA) $@

# $(2)/libsl.a: $($(3)_libsl_a_CONTENTS)
# $(2)/libm.a: $($(3)_libm_a_CONTENTS)

# enddef

### Target-neutral libraries

nobase_pkglib_DATA += \
   mtalpha-sim/libm.a \
   mtalpha-sim/libmalloc_notls.a

mtalpha_sim_libm_a_CONTENTS = \
	$(MTAMATHOBJS) \
	mta_missing_uclibc_math.o

mtalpha_sim_libmalloc_notls_a_CONTENTS = \
	mta_malloc_wrappers.o

# we do not use mtalpha_sim_libm_a_CONTENTS in CLEANFILES below
# because we want to preserve the MTAMATHOBJS
CLEANFILES += \
	mta_missing_uclibc_math.o \
	$(mtalpha_sim_libmalloc_notls_a_CONTENTS) \
	mtalpha-sim/libm.a \
	mtalpha-sim/libmalloc_notls.a

mtalpha-sim/%.a:
	$(AM_V_at)rm -f $@
	$(AM_V_at)$(MKDIR_P) mtalpha-sim
	$(AM_V_AR)$(AR_MTALPHA) cru $@ $^
	$(AM_V_at)$(RANLIB_MTALPHA) $@

mtalpha-sim/libm.a: $(mtalpha_sim_libm_a_CONTENTS)
mtalpha-sim/libmalloc_notls.a: $(mtalpha_sim_libmalloc_notls_a_CONTENTS)

### MT-hybrid targets

#$(eval $(call MTA_TEMPLATE,mta,mta_hybrid-mtalpha-sim,mta_hybrid_mtalpha_sim)

nobase_pkglib_DATA += \
   mta_hybrid-mtalpha-sim/libsl.a

mta_hybrid_mtalpha_sim_libsl_a_CONTENTS = \
	$(MTALIB_COBJS) \
	$(addprefix mta_hybrid-mtalpha-sim/gdtoa_,$(addsuffix .o,$(notdir $(basename $(GDTOA_SRC))))) \
	$(addprefix mta_hybrid-mtalpha-sim/,$(addsuffix .o,$(notdir $(basename $(MTALIB_SRC))))) \
	$(addprefix mta_hybrid-mtalpha-sim/,$(addsuffix .o,$(notdir $(basename $(MTALIB_SIM_SRC)))))

CLEANFILES += \
	$(mta_hybrid_mtalpha_sim_libsl_a_CONTENTS) \
	mta_hybrid-mtalpha-sim/libsl.a

mta_hybrid-mtalpha-sim/%.o: $(srcdir)/src/%.c
	$(AM_V_at)$(MKDIR_P) mta_hybrid-mtalpha-sim
	$(slc_verbose)$(SLC_MTA) -c -o $@ $<

mta_hybrid-mtalpha-sim/gdtoa_%.o: $(srcdir)/src/gdtoa/%.c
	$(AM_V_at)$(MKDIR_P) mta_hybrid-mtalpha-sim
	$(slc_verbose)$(SLC_MTA) -c -o $@ $<

mta_hybrid-mtalpha-sim/%.a:
	$(AM_V_at)rm -f $@
	$(AM_V_AR)$(AR_MTALPHA) cru $@ $^
	$(AM_V_at)$(RANLIB_MTALPHA) $@

mta_hybrid-mtalpha-sim/libsl.a: $(mta_hybrid_mtalpha_sim_libsl_a_CONTENTS)

### seq-naked targets

#$(eval $(call MTA_TEMPLATE,mta_s,seq_naked-mtalpha-sim,seq_naked_mtalpha_sim)

nobase_pkglib_DATA += \
   seq_naked-mtalpha-sim/libsl.a

seq_naked_mtalpha_sim_libsl_a_CONTENTS = \
	$(MTALIB_COBJS) \
	$(addprefix seq_naked-mtalpha-sim/gdtoa_,$(addsuffix .o,$(notdir $(basename $(GDTOA_SRC))))) \
	$(addprefix seq_naked-mtalpha-sim/,$(addsuffix .o,$(notdir $(basename $(MTALIB_SRC))))) \
	$(addprefix seq_naked-mtalpha-sim/,$(addsuffix .o,$(notdir $(basename $(MTALIB_SIM_SRC)))))

CLEANFILES += \
	$(seq_naked_mtalpha_sim_libsl_a_CONTENTS) \
	seq_naked-mtalpha-sim/libsl.a

SLC_MTA_S = $(SLC_RUN) -b mta_s $(SHUTUP)

seq_naked-mtalpha-sim/%.o: $(srcdir)/src/%.c
	$(AM_V_at)$(MKDIR_P) seq_naked-mtalpha-sim
	$(slc_verbose)$(SLC_MTA_S) -c -o $@ $<

seq_naked-mtalpha-sim/gdtoa_%.o: $(srcdir)/src/gdtoa/%.c
	$(AM_V_at)$(MKDIR_P) seq_naked-mtalpha-sim
	$(slc_verbose)$(SLC_MTA_S) -c -o $@ $<

seq_naked-mtalpha-sim/%.a:
	$(AM_V_at)rm -f $@
	$(AM_V_AR)$(AR_MTALPHA) cru $@ $^
	$(AM_V_at)$(RANLIB_MTALPHA) $@

seq_naked-mtalpha-sim/libsl.a: $(seq_naked_mtalpha_sim_libsl_a_CONTENTS)

### MT-naked targets

#$(eval $(call MTA_TEMPLATE,mta_n,mta_naked-mtalpha-sim,mta_naked_mtalpha_sim)

nobase_pkglib_DATA += \
   mta_naked-mtalpha-sim/libsl.a

mta_naked_mtalpha_sim_libsl_a_CONTENTS = \
	$(MTALIB_COBJS) \
	$(addprefix mta_naked-mtalpha-sim/gdtoa_,$(addsuffix .o,$(notdir $(basename $(GDTOA_SRC))))) \
	$(addprefix mta_naked-mtalpha-sim/,$(addsuffix .o,$(notdir $(basename $(MTALIB_SRC))))) \
	$(addprefix mta_naked-mtalpha-sim/,$(addsuffix .o,$(notdir $(basename $(MTALIB_SIM_SRC)))))

CLEANFILES += \
	$(mta_naked_mtalpha_sim_libsl_a_CONTENTS) \
	mta_naked-mtalpha-sim/libsl.a

SLC_MTA_N = $(SLC_RUN) -b mta_n $(SHUTUP)

mta_naked-mtalpha-sim/%.o: $(srcdir)/src/%.c
	$(AM_V_at)$(MKDIR_P) mta_naked-mtalpha-sim
	$(slc_verbose)$(SLC_MTA_N) -c -o $@ $<

mta_naked-mtalpha-sim/gdtoa_%.o: $(srcdir)/src/gdtoa/%.c
	$(AM_V_at)$(MKDIR_P) mta_naked-mtalpha-sim
	$(slc_verbose)$(SLC_MTA_N) -c -o $@ $<

mta_naked-mtalpha-sim/%.a:
	$(AM_V_at)rm -f $@
	$(AM_V_AR)$(AR_MTALPHA) cru $@ $^
	$(AM_V_at)$(RANLIB_MTALPHA) $@

mta_naked-mtalpha-sim/libsl.a: $(mta_naked_mtalpha_sim_libsl_a_CONTENTS)


endif

