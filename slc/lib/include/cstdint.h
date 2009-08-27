//
// cstdint.h: this file is part of the SL toolchain.
//
// Copyright (C) 2009 The SL project.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 3
// of the License, or (at your option) any later version.
//
// The complete GNU General Public Licence Notice can be found as the
// `COPYING' file in the root directory.
//

#ifndef SLC_CSTDINT_H
# define SLC_CSTDINT_H

#ifdef __mt_freestanding__

#if defined(__alpha__)||defined(__mtalpha__)

/* 7.18.1.1 Exact-width integer types */
typedef signed char             int8_t;
typedef unsigned char           uint8_t;
typedef short int               int16_t;
typedef unsigned short int      uint16_t;
typedef int                     int32_t;
typedef unsigned int            uint32_t;
# if __WORDSIZE == 64
typedef long int                int64_t;
typedef unsigned long int       uint64_t;
# else
typedef long long int           int64_t;
typedef unsigned long long int  uint64_t;
# endif


/* 7.18.1.2 Minimum-width integer types */

typedef signed char             int_least8_t;
typedef unsigned char           uint_least8_t;
typedef short int               int_least16_t;
typedef unsigned short int      uint_least16_t;
typedef int                     int_least32_t;
typedef unsigned int            uint_least32_t;
#if __WORDSIZE == 64
typedef long int                int_least64_t;
typedef unsigned long int       uint_least64_t;
#else
typedef long long int           int_least64_t;
typedef unsigned long long int  uint_least64_t;
#endif


/* 7.18.1.3 Fastest-width integer types */
typedef signed char             int_fast8_t;
typedef unsigned char           uint_fast8_t;
#if __WORDSIZE == 64
typedef long int                int_fast16_t;
typedef long int                int_fast32_t;
typedef long int                int_fast64_t;
typedef unsigned long int       uint_fast16_t;
typedef unsigned long int       uint_fast32_t;
typedef unsigned long int       uint_fast64_t;
#else
typedef int                     int_fast16_t;
typedef int                     int_fast32_t;
typedef long long int           int_fast64_t;
typedef unsigned int            uint_fast16_t;
typedef unsigned int            uint_fast32_t;
typedef unsigned long long int  uint_fast64_t;
#endif

/* 7.18.1.4 Integer types capable of holding object pointers */

#if __WORDSIZE == 64
typedef long int                intptr_t;
typedef unsigned long int       uintptr_t;
#else
typedef int                     intptr_t;
typedef unsigned int            uintptr_t;
#endif

/* 7.18.1.5 Greatest-width integer types */

#if __WORDSIZE == 64
typedef long int                intmax_t;
typedef unsigned long int       uintmax_t;
#else
typedef long long int           intmax_t;
typedef unsigned long long int  uintmax_t;
#endif

/* 7.18.2.1 Limits of exact-width integer types */

# if __WORDSIZE == 64
#  define __INT64_C(c)  c ## L
#  define __UINT64_C(c) c ## UL
# else
#  define __INT64_C(c)  c ## LL
#  define __UINT64_C(c) c ## ULL
# endif

/* Minimum of signed integral types.  */
# define INT8_MIN               (-128)
# define INT16_MIN              (-32767-1)
# define INT32_MIN              (-2147483647-1)
# define INT64_MIN              (-__INT64_C(9223372036854775807)-1)
/* Maximum of signed integral types.  */
# define INT8_MAX               (127)
# define INT16_MAX              (32767)
# define INT32_MAX              (2147483647)
# define INT64_MAX              (__INT64_C(9223372036854775807))

/* Maximum of unsigned integral types.  */
# define UINT8_MAX               (255)
# define UINT16_MAX              (65535)
# define UINT32_MAX              (4294967295U)
# define UINT64_MAX              (__UINT64_C(18446744073709551615))

/* 7.18.2.2 Limits of minimum-width integer types */

/* Minimum of signed integral types having a minimum size.  */
# define INT_LEAST8_MIN         (-128)
# define INT_LEAST16_MIN        (-32767-1)
# define INT_LEAST32_MIN        (-2147483647-1)
# define INT_LEAST64_MIN        (-__INT64_C(9223372036854775807)-1)
/* Maximum of signed integral types having a minimum size.  */
# define INT_LEAST8_MAX         (127)
# define INT_LEAST16_MAX        (32767)
# define INT_LEAST32_MAX        (2147483647)
# define INT_LEAST64_MAX        (__INT64_C(9223372036854775807))

/* Maximum of unsigned integral types having a minimum size.  */
# define UINT_LEAST8_MAX        (255)
# define UINT_LEAST16_MAX       (65535)
# define UINT_LEAST32_MAX       (4294967295U)
# define UINT_LEAST64_MAX       (__UINT64_C(18446744073709551615))

/* 7.18.2.3 Limits of fastest minimum-width integer types */

/* Minimum of fast signed integral types having a minimum size.  */
# define INT_FAST8_MIN          (-128)
# if __WORDSIZE == 64
#  define INT_FAST16_MIN        (-9223372036854775807L-1)
#  define INT_FAST32_MIN        (-9223372036854775807L-1)
# else
#  define INT_FAST16_MIN        (-2147483647-1)
#  define INT_FAST32_MIN        (-2147483647-1)
# endif
# define INT_FAST64_MIN         (-__INT64_C(9223372036854775807)-1)
/* Maximum of fast signed integral types having a minimum size.  */
# define INT_FAST8_MAX          (127)
# if __WORDSIZE == 64
#  define INT_FAST16_MAX        (9223372036854775807L)
#  define INT_FAST32_MAX        (9223372036854775807L)
# else
#  define INT_FAST16_MAX        (2147483647)
#  define INT_FAST32_MAX        (2147483647)
# endif
# define INT_FAST64_MAX         (__INT64_C(9223372036854775807))

/* 7.18.2.4 Limits of integer types capable of holding object pointers */

# if __WORDSIZE == 64
#  define INTPTR_MIN            (-9223372036854775807L-1)
#  define INTPTR_MAX            (9223372036854775807L)
#  define UINTPTR_MAX           (18446744073709551615UL)
# else
#  define INTPTR_MIN            (-2147483647-1)
#  define INTPTR_MAX            (2147483647)
#  define UINTPTR_MAX           (4294967295U)
# endif

/* 7.18.2.5 Limits of greatest-width integer types */

/* Minimum for largest signed integral type.  */
# define INTMAX_MIN             (-__INT64_C(9223372036854775807)-1)
/* Maximum for largest signed integral type.  */
# define INTMAX_MAX             (__INT64_C(9223372036854775807))

/* Maximum for largest unsigned integral type.  */
# define UINTMAX_MAX            (__UINT64_C(18446744073709551615))

/* 7.18.3 "Other" */

# if __WORDSIZE == 64
#  define PTRDIFF_MIN           (-9223372036854775807L-1)
#  define PTRDIFF_MAX           (9223372036854775807L)
# else
#  define PTRDIFF_MIN           (-2147483647-1)
#  define PTRDIFF_MAX           (2147483647)
# endif

/* Limits of `sig_atomic_t'.  */
# define SIG_ATOMIC_MIN         (-2147483647-1)
# define SIG_ATOMIC_MAX         (2147483647)

/* Limit of `size_t' type.  */
# if __WORDSIZE == 64
#  define SIZE_MAX              (18446744073709551615UL)
# else
#  define SIZE_MAX              (4294967295U)
# endif

/* Limits of `wchar_t'.  */
# ifndef WCHAR_MIN
/* These constants might also be defined in <wchar.h>.  */
#  define WCHAR_MIN             __WCHAR_MIN
#  define WCHAR_MAX             __WCHAR_MAX
# endif

/* Limits of `wint_t'.  */
# define WINT_MIN               (0u)
# define WINT_MAX               (4294967295u)

/* 7.18.4 Macros for integer constants */

/* Signed.  */
# define INT8_C(c)      c
# define INT16_C(c)     c
# define INT32_C(c)     c
# if __WORDSIZE == 64
#  define INT64_C(c)    c ## L
# else
#  define INT64_C(c)    c ## LL
# endif

/* Unsigned.  */
# define UINT8_C(c)     c ## U
# define UINT16_C(c)    c ## U
# define UINT32_C(c)    c ## U
# if __WORDSIZE == 64
#  define UINT64_C(c)   c ## UL
# else
#  define UINT64_C(c)   c ## ULL
# endif

/* Maximal type.  */
# if __WORDSIZE == 64
#  define INTMAX_C(c)   c ## L
#  define UINTMAX_C(c)  c ## UL
# else
#  define INTMAX_C(c)   c ## LL
#  define UINTMAX_C(c)  c ## ULL
# endif

#else
# warning No stdint.h definitions available for this target.
#endif

#else

#include <stdint.h>

#endif

#endif // ! SLC_CSTDINT_H