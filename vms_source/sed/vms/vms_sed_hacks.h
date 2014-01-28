#ifndef __VMS_SED_HACKS_H__
#define __VMS_SED_HACKS_H__

#ifndef GNULIB_MALLOC_GNU
#define GNULIB_MALLOC_GNU 1
#endif

#define GNULIB_CANONICALIZE_LGPL 1
#ifdef GNULIB_FSCANF
#undef GNULIB_FSCANF
#endif
#define GNULIB_FSCANF 1
#ifdef GNULIB_MKOSTEMP
#undef GNULIB_MKOSTEMP
#endif
#define GNULIB_MKOSTEMP 1
#ifdef GNULIB_SCANF
#undef GNULIB_SCANF
#endif
#define GNULIB_SCANF 1
#ifdef GNULIB_STRERROR
#undef GNULIB_STRERROR
#endif
#define GNULIB_STRERROR 1
#define GNULIB_TEST_BTOWC 1
#define GNULIB_TEST_CANONICALIZE_FILE_NAME 1
#define GNULIB_TEST_CHDIR 1
#define GNULIB_TEST_FSTAT 1
#define GNULIB_TEST_GETDELIM 1
#define GNULIB_TEST_GETOPT_GNU 1
#define GNULIB_TEST_GETTIMEOFDAY 1
#define GNULIB_TEST_LOCALECONV 1
#define GNULIB_TEST_LSTAT 1
#define GNULIB_TEST_MALLOC_POSIX 1
#define GNULIB_TEST_MBRLEN 1
#define GNULIB_TEST_MBRTOWC 1
#define GNULIB_TEST_MBSINIT 1
#define GNULIB_TEST_MBTOWC 1
#define GNULIB_TEST_MEMCHR 1
#define GNULIB_TEST_MKOSTEMP 1
#define GNULIB_TEST_NL_LANGINFO 1
#define GNULIB_TEST_READLINK 1
#define GNULIB_TEST_REALLOC_POSIX 1
#define GNULIB_TEST_REALPATH 1
#define GNULIB_TEST_RENAME 1
#define GNULIB_TEST_RMDIR 1
#define GNULIB_TEST_STAT 1
#define GNULIB_TEST_STRERROR 1
#define GNULIB_TEST_STRVERSCMP 1
#define GNULIB_TEST_WCRTOMB 1
#define GNULIB_TEST_WCTOB 1
#define GNULIB_TEST_WCTOMB 1
#define __GETOPT_PREFIX rpl_

#define re_comp rpl_re_comp
#define re_compile_fastmap rpl_re_compile_fastmap
#define re_compile_pattern rpl_re_compile_pattern
#define re_exec rpl_re_exec
#define re_match rpl_re_match
#define re_match_2 rpl_re_match_2
#define re_search rpl_re_search
#define re_search_2 rpl_re_search_2
#define re_set_registers rpl_re_set_registers
#define re_set_syntax rpl_re_set_syntax
#define re_syntax_options rpl_re_syntax_options

#define _REGEX_INCLUDE_LIMITS_H 1
#define _REGEX_LARGE_OFFSETS 1
#define _GNU_SOURCE 1
#define _POSIX_PTHREAD_SEMANTICS 1

#ifdef HAVE_FOPEN_RT
#undef HAVE_FOPEN_RT
#endif
#define HAVE_WORKING_O_NOATIME 1
#define HAVE_WORKING_O_NOFOLLOW 1
#define RENAME_HARD_LINK_BUG 1
#define RENAME_TRAILING_SLASH_DEST_BUG 1
#define RENAME_TRAILING_SLASH_SOURCE_BUG 1

#ifndef HAVE_DECL_STRERROR_R
#define HAVE_DECL_STRERROR_R (0)
#endif

#define gl_va_copy(a,b) ((a) = (b))
#define va_copy gl_va_copy

#define _GL_ARG_NONNULL(params)
#define _GL_UNUSED_PARAMETER
#ifdef _GL_INLINE
#undef _GL_INLINE
#endif
#define _GL_INLINE static inline

#define __UNIX_PUTC

#pragma message disable promotmatchw

/* Seen in utils.c */
#pragma message disable questcompare

/* testsuite/runtests.c needs this */
#pragma message disable ptrmismatch1

#ifdef __VAX
#pragma message disable longdoublenyi
#define lstat stat
#endif


#include <stdio.h>
static _Bool vms_fwriting(FILE * fp) {
    struct _iobuf * stream;
    stream = (struct _iobuf *) fp;
    return (stream->_flag & _IOWRT) != 0;
}
#define fwriting vms_fwriting

#define LIBDIR "/usr/local/lib"

/* Missing declarations */
/* in compile.c */
int strverscmp (const char *s1, const char *s2);

/* same-inode.h has VMS specific hack that is now wrong. */
/* Disable the header file if it is not needed. */
#ifdef _USE_STD_STAT
#define SAME_INODE_H 1
#  define SAME_INODE(a, b)    \
    ((a).st_ino == (b).st_ino \
     && (a).st_dev == (b).st_dev)
#endif


/* Fix up the argv[0] program name to be like Unix */
#ifdef MOD_SED
#include "vms_main_wrapper.c"
#endif

#ifdef MOD_UTILS
int mkostemp(char *xtemplate, int flags);
size_t getdelim(char **buf, size_t *buflen,
                char buffer_delimiter, FILE *stream);
#endif

/* VAX/VMS 7.3 does not have EOVERFLOW */
#include <errno.h>
#ifndef EOVERFLOW
#define EOVERFLOW EIO
#endif

/* This is a hack to attempt to speed up SED on VMS */
/* It did not work, it actually doubles the time of the dc test */

#ifdef VMS_STREAM_HACK

extern char buffer_delimiter;

static FILE *vms_fopen(const char * fn, const char * mode) {
    if ((buffer_delimiter == '\n') && (mode[0] == 'r') && (mode[1] == 0)) {
        return fopen(fn, mode, "ctx=rec");
    }
    return fopen(fn, mode);
}

#define fopen vms_fopen

#ifdef MOD_UTILS

#include <stdlib.h>

extern char *read_mode;


/* Optimization needed for VMS */
static size_t vms_getdelim(char **buf, size_t *buflen,
                           char buffer_delimiter, FILE *stream) {

    if ((buffer_delimiter == '\n') &&
        (read_mode[0] == 'r') && (read_mode[1] == 0)) {

        /* On VMS doing a record read is significantly faster than */
        /* doing single character reads */
        char * buffer;
        int len;

        buffer = malloc(65536);
        *buf = buffer;
        *buflen = 65535;
        if (buffer != NULL) {
            len = decc$record_read(stream, buffer, *buflen);
            buffer[len] = 0;
            return len;
        } else {
            return -1;
        }
    }
    return getdelim(buf, buflen, buffer_delimiter, stream);
}

#define getdelim vms_getdelim

#endif /* MOD_UTILS */

#endif /* VMS_STREAM_HACK */


#endif /* __VMS_SED_HACKS_H__ */
