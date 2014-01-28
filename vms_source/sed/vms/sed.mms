# File: sed.mms
#
# Quick and dirty Make file for building Sed on VMS
#
# This build procedure requires the following concealed rooted
# logical names to be set up.
# LCL_ROOT: This is a read/write directory for the build output.
# VMS_ROOT: This is a read only directory for VMS specific changes
#           that have not been checked into the official repository.
# SRC_ROOT: This is a read only directory containing the files in the
#           Offical repository.
# PRJ_ROOT: This is a search list of LCL_ROOT:,VMS_ROOT:,SRC_ROOT:
#
# Copyright 2014, John Malmberg
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
# OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# 18-Jan-2014   J. Malmberg	First pass for sed
##############################################################################
crepository = /repo=sys$disk:[coreutils.cxx_repository]
cnames = /name=(as_i,shor)$(crepository)
cshow = /show=(EXPA,INC)
.ifdef __IA64__
clist = /list$(cshow)
.else
clist = /list/mach$(cshow)
.endif
.ifdef __VAX__
cprefix = /pref=all
.else
cprefix = /prefix=(all,exce=(strtoimax,strtoumax))
cfloat = /FLOAT=IEEE_FLOAT/IEEE_MODE=DENORM_RESULTS
.endif
#cnowarn1 = noparmlist,questcompare2,unusedtop,unknownmacro
#cnowarn2 = intconcastsgn,controlassign,exprnotused,unreachcode
#cnowarn = $(cnowarn1),$(cnowarn2)
#cwarn = /warnings=(disable=($(cnowarn)))
#cinc1 = prj_root:[],prj_root:[.include],prj_root:[.lib.intl],prj_root:[.lib.sh]
cinc2 = /nested=none
cinc = $(cinc2)
#cdefs = /define=(_USE_STD_STAT=1,_POSIX_EXIT=1,\
#	HAVE_STRING_H=1,HAVE_STDLIB_H=1,HAVE_CONFIG_H=1,SHELL=1)
.ifdef __VAX__
cdefs1 = _POSIX_EXIT=1,HAVE_CONFIG_H=1
cdefs2 = _POSIX_EXIT=1,MSDOS,MOD_SED
cdefs3 = _POSIX_EXIT=1,MOD_UTILS=1
cmain =
.else
cdefs1 = _USE_STD_STAT,_POSIX_EXIT=1,HAVE_CONFIG_H=1
cdefs2 = _USE_STD_STAT,_POSIX_EXIT=1,MSDOS,MOD_SED
cdefs3 = _USE_STD_STAT,_POSIX_EXIT=1,MOD_UTILS
cmain = /MAIN=POSIX_EXIT
.endif
cdefs2a = $(cdefs2),VMS_STREAM_HACK
cdefs3a = $(cdefs3),VMS_STREAM_HACK
cdefs = /define=($(cdefs1))$(cmain)
sed_defs = /define=($(cdefs2))$(cmain)
sed_defs_a = /define=($(cdefs2a))$(cmain)
utils_defs = /define=($(cdefs3))$(cmain)
utils_defs_a = /define=($(cdefs3a))$(cmain)
cflags = $(cnames)/debu$(clist)$(cprefix)$(cwarn)$(cinc)$(cdefs)$(cfloat)
cflagsx = $(cnames)/debu$(clist)$(cwarn)$(cinc2)$(cfloat)$(cmain)
cflags_sed = $(cnames)/debu$(clist)$(cprefix)$(cwarn)$(cinc)$(sed_defs)$(cfloat)
cflags_sed_a = \
    $(cnames)/debu$(clist)$(cprefix)$(cwarn)$(cinc)$(sed_defs_a)$(cfloat)
cflags_utils = \
    $(cnames)/debu$(clist)$(cprefix)$(cwarn)$(cinc)$(utils_defs)$(cfloat)
cflags_utils_a = \
    $(cnames)/debu$(clist)$(cprefix)$(cwarn)$(cinc)$(utils_defs_a)$(cfloat)

#
# TPU symbols
#===================

UNIX_2_VMS = /COMM=prj_root:[.vms]unix_c_to_vms_c.tpu

EVE = EDIT/TPU/SECT=EVE$SECTION/NODISP

.SUFFIXES
.SUFFIXES .exe .olb .obj .c .def

#.SUFFIXES .1 .c .dvi .html .log .o .obj .pl .pl.exe \
#	.ps .sed .sh .sh.exe .sin .x .xpl .xpl.exe .y

.obj.exe
   $(LINK)$(LFLAGS)/NODEBUG/EXE=$(MMS$TARGET)/DSF=$(MMS$TARGET_NAME)\
     /MAP=$(MMS$TARGET_NAME) $(MMS$SOURCE_LIST)

.c.obj
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.testsuite]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.vms]
   $(CC)$(CFLAGS)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

.obj.olb
   @ if f$search("$(MMS$TARGET)") .eqs. "" then \
	librarian/create/object $(MMS$TARGET)
   $ librarian/replace $(MMS$TARGET) $(MMS$SOURCE_LIST)

config_h = config.h config_vms.h [.vms]vms_sed_hacks.h

basicdefs_h = basicdefs.h [.lib]alloca.h

utils_h = [.sed]utils.h $(basicdefs_h)

sed_h = [.sed]sed.h $(config_h) $(basicdefs_h) [.lib]regex.h \
	[.lib]unlocked-io.h $(utils_h)

acl_internal_h = [.lib]acl-internal.h [.lib]acl.h [.lib]error.h [.lib]quote.h

xalloc_h = [.lib]xalloc.h [.lib]xalloc-oversized.h

regex_internal_h = [.lib]regex_internal.h [.lib]stdint.h

sed_objects = sed.obj compile.obj execute.obj regexp.obj fmt.obj \
	mbcs.obj utils.obj vms_crtl_init.obj

c_strcaseeq_h = [.lib]c-strcaseeq.h [.lib]c-strcase.h [.lib]c-ctype.h

libsed_objects = "c-strcasecmp"=[.lib]c-strcasecmp.obj, \
		"c-ctype"=[.lib]c-ctype.obj, \
		"copy-acl"=[.lib]copy-acl.obj, \
		"error"=[.lib]error.obj, \
		"exitfail"=[.lib]exitfail.obj, \
		"getdelim"=[.lib]getdelim.obj, \
		"getopt"=[.lib]getopt.obj, \
		"getopt1"=[.lib]getopt1.obj, \
		"localcharset"=[.lib]localcharset.obj, \
		"mkostemp"=[.lib]mkostemp.obj, \
		"obstack"=[.lib]obstack.obj, \
		"quotearg"=[.lib]quotearg.obj, \
		"regex"=[.lib]regex.obj, \
		"set-mode-acl"=[.lib]set-mode-acl.obj, \
		"strverscmp"=[.lib]strverscmp.obj, \
		"tempname"=[.lib]tempname.obj, \
		"version-etc"=[.lib]version-etc.obj, \
		"version-etc-fsf"=[.lib]version-etc-fsf.obj, \
		"xalloc-die"=[.lib]xalloc-die.obj, \
		"xmalloc"=[.lib]xmalloc.obj

#bug-regex14.exe tst-boost.exe tst-pcre.exe tst-rxspencer.exe skipped for now.
check_PROGRAMS = bug-regex7.exe \
	bug-regex8.exe bug-regex9.exe \
	bug-regex10.exe bug-regex11.exe \
	bug-regex12.exe bug-regex13.exe \
	bug-regex15.exe \
	bug-regex16.exe bug-regex21.exe \
	bug-regex27.exe bug-regex28.exe \
	runtests.exe runptests.exe \
	tst-regex2.exe


all : gnv$sed.exe, sed_debug.exe, sed_hack.exe, sed_hack_debug.exe

check : gnv$sed.exe $(check_PROGRAMS)

gnv$sed.exe : $(sed_objects) [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) sed.obj, compile.obj, execute.obj, \
		regexp.obj, fmt.obj, mbcs.obj, utils.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

sed_debug.exe : $(sed_objects) [.lib]libsed.olb vms_crtl_init.obj
	link/debug/exe=$(MMS$TARGET) sed.obj, compile.obj, execute.obj, \
		regexp.obj, fmt.obj, mbcs.obj, utils.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

sed_hack.exe : $(sed_objects) [.lib]libsed.olb vms_crtl_init.obj \
		sed_hack.obj, utils_hack.obj
	link/exe=$(MMS$TARGET) sed_hack.obj, compile.obj, execute.obj, \
		regexp.obj, fmt.obj, mbcs.obj, utils_hack.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

sed_hack_debug.exe : $(sed_hack_objects) [.lib]libsed.olb vms_crtl_init.obj \
		sed_hack.obj, utils_hack.obj
	link/debug/exe=$(MMS$TARGET) sed_hack.obj, compile.obj, execute.obj, \
		regexp.obj, fmt.obj, mbcs.obj, utils_hack.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

[.lib]libsed.olb : [.lib]libsed($(libsed_objects))
    @ write sys$output "libcoreutils is up to date"


config.h : [.vms]config_h.com config_vms.h config_h.in configure.
	@[.vms]config_h.com
	write sys$output "[.lib]config.h target built."

config_vms.h : [.vms]generate_config_vms_h_sed.com
	$ @[.vms]generate_config_vms_h_sed.com

[.lib]alloca.h : [.vms]vms_alloca.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

.ifdef __VAX__
getopt_in_h = [.lib]getopt.in$5nh
.else
getopt_in_h = [.lib]getopt.in.h
.endif
[.lib]getopt.h : $(getopt_in_h) [.vms]lib_getopt_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

.ifdef __VAX__
context_in_h = [.lib]se-context.in$5nh
.else
context_in_h = [.lib]se-context^.in.h
.endif
[.lib.selinux]context.h : $(context_in_h)
	if f$search("[.lib]selinux.dir") .eqs. "" then \
	    create/dir sys$disk:[.lib.selinux]/prot=o:rwed
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

.ifdef __VAX__
selinux_in_h = [.lib]se-selinux.in$5nh
.else
selinux_in_h = [.lib]se-selinux^.in.h
.endif
[.lib.selinux]selinux.h : $(selinux_in_h) \
	[.vms]lib_selinux_selinux_h.tpu
    if f$search("[.lib]selinux.dir") .eqs. "" then \
	create/dir sys$disk:[.lib.selinux]/prot=o:rwed
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

.ifdef __VAX__
stdint_in_h = [.lib]stdint.in$5nh
.else
stdint_in_h = [.lib]stdint^.in.h
.endif
[.lib]stdint.h : $(stdint_in_h) [.vms]lib_stdint_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

compile.obj : [.sed]compile.c $(sed_h) [.lib.selinux]selinux.h

execute.obj : [.sed]execute.c $(sed_h) [.lib]stat-macros.h [.lib]acl.h \
	[.lib.selinux]context.h

fmt.obj : [.sed]fmt.c $(sed_h)

mbcs.obj : [.sed]mbcs.c $(sed_h) [.lib]localcharset.h

regexp.obj : [.sed]regexp.c $(sed_h)

sed.obj : [.sed]sed.c $(sed_h) [.lib]getopt.h [.lib]version-etc.h
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.testsuite]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.vms]
   $(CC)$(CFLAGS_SED)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

sed_hack.obj : [.sed]sed.c $(sed_h) [.lib]getopt.h [.lib]version-etc.h
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.testsuite]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.vms]
   $(CC)$(CFLAGS_SED_A)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

utils.obj : [.sed]utils.c $(config_h) $(util_h) [.lib]pathmax.h \
	[.lib]fwriting.h
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.testsuite]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.vms]
   $(CC)$(CFLAGS_UTILS)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

utils_hack.obj : [.sed]utils.c $(config_h) $(util_h) [.lib]pathmax.h \
	[.lib]fwriting.h
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.testsuite]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.sed],sys$disk:[.vms]
   $(CC)$(CFLAGS_UTILS_A)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

vms_crtl_init.obj : [.vms]vms_crtl_init.c
	$(CC)$(cflagsx)/define="GNV_UNIX_TOOL=1" \
	/object=$(MMS$TARGET) $(MMS$SOURCE)

[.lib]c-strcasecmp.obj : [.lib]c-strcasecmp.c $(config_h) [.lib]c-strcase.h \
			[.lib]c-ctype.h

[.lib]c-ctype.obj : [.lib]c-ctype.c $(config_h) [.lib]c-ctype.h

[.lib]copy-acl.obj : [.lib]copy-acl.c $(config_h) [.lib]acl.h \
			$(acl_internal_h) [.lib]gettext.h

[.lib]error.obj : [.lib]error.c $(config_h) [.lib]gettext.h \
			[.lib]stdint.h [.lib]unlocked-io.h

[.lib]exitfail.obj : [.lib]exitfail.c $(config_h) [.lib]exitfail.h

[.lib]fwriting.obj : [.lib]fwriting.c $(config_h) [.lib]fwriting.h \
			[.lib]stdio-impl.h

[.lib]getdelim.obj : [.lib]getdelim.c $(config_h) [.lib]unlocked-io.h \
			[.lib]stdint.h

[.lib]getopt.obj : [.lib]getopt.c [.lib]getopt.h [.lib]getopt_int.h \
	[.lib]gettext.h

[.lib]getopt1.obj : [.lib]getopt1.c [.lib]getopt.h $(config_h) \
			[.lib]getopt_int.h

[.lib]localcharset.obj : [.lib]localcharset.c $(config_h) \
			[.lib]localcharset.h

[.lib]mkostemp.obj : [.lib]mkostemp.c $(config_h) [.lib]tempname.h

[.lib]obstack.obj : [.lib]obstack.c [.lib]obstack.h $(config_h) \
			[.lib]exitfail.h [.lib]gettext.h [.lib]stdint.h

[.lib]quote-arg.obj : [.lib]quote-arg.c $(config_h) [.lib]quotearg.h \
			[.lib]quote.h [.lib]xalloc.h $(c_strcaseeq_h) \
			[.lib]localcharset.h [.lib]gettext.h

[.lib]regex.obj : [.lib]regex.c $(config_h) [.lib]regex.h \
			$(regex_internal_h) [.lib]regex_internal.c \
			[.lib]regcomp.c [.lib]regexec.c [.lib]alloca.h

[.lib]set-mode-acl.obj : [.lib]set-mode-acl.c $(config_h) [.lib]acl.h \
			$(acl_internal_h) [.lib]gettext.h

[.lib]strverscmp.obj : [.lib]strverscmp.c $(config_h)

[.lib]tempname.obj : [.lib]tempname.c $(config_h) [.lib]tempname.h \
			[.lib]stdint.h

[.lib]version-etc.obj : [.lib]version-etc.c $(config_h) \
			[.lib]version-etc.h [.lib]unlocked-io.h \
			[.lib]gettext.h

[.lib]version-etc-fsf.obj : [.lib]version-etc-fsf.c $(config_h) \
			[.lib]version-etc.h

[.lib]xalloc-die.obj : [.lib]xalloc-die.c $(config_h) $(xalloc_h) \
			[.lib]error.h [.lib]exitfail.h [.lib]gettext.h

[.lib]xmalloc.obj : [.lib]xmalloc.c $(config_h) $(xalloc_h)


bug-regex10.exe : [.testsuite]bug-regex10.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex10.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex11.exe : [.testsuite]bug-regex11.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex11.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex12.exe : [.testsuite]bug-regex12.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex12.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex13.exe : [.testsuite]bug-regex13.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex13.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

#bug-regex14.exe : [.testsuite]bug-regex14.obj [.lib]libsed.olb vms_crtl_init.obj
#	link/exe=$(MMS$TARGET) [.testsuite]bug-regex14.obj, \
#		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex15.exe : [.testsuite]bug-regex15.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex15.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex16.exe : [.testsuite]bug-regex16.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex16.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex21.exe : [.testsuite]bug-regex21.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex21.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex27.exe : [.testsuite]bug-regex27.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex27.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex28.exe : [.testsuite]bug-regex28.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex28.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex7.exe : [.testsuite]bug-regex7.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex7.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex8.exe : [.testsuite]bug-regex8.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex8.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

bug-regex9.exe : [.testsuite]bug-regex9.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]bug-regex9.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

runptests.exe : [.testsuite]runptests.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]runptests.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

runtests.exe : [.testsuite]runtests.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]runtests.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

tst-boost.exe : [.testsuite]tst-boost.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]tst-boost.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

tst-pcre.exe : [.testsuite]tst-pcre.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]tst-pcre.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

tst-regex2.exe : [.testsuite]tst-regex2.obj [.lib]libsed.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]tst-regex2.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

tst-rxspencer.exe : [.testsuite]tst-rxspencer.obj [.lib]libsed.olb \
		vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.testsuite]tst-rxspencer.obj, \
		sys$disk:[.lib]libsed.olb/lib, sys$disk:[]vms_crtl_init.obj

[.testsuite]bug-regex8.obj : [.testsuite]bug-regex8.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex9.obj : [.testsuite]bug-regex9.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex10.obj : [.testsuite]bug-regex10.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex11.obj : [.testsuite]bug-regex11.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex12.obj : [.testsuite]bug-regex12.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex13.obj : [.testsuite]bug-regex13.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex14.obj : [.testsuite]bug-regex14.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex15.obj : [.testsuite]bug-regex15.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex16.obj : [.testsuite]bug-regex16.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex21.obj : [.testsuite]bug-regex21.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex27.obj : [.testsuite]bug-regex27.c \
	$(config_h) [.lib]regex.h

[.testsuite]bug-regex28.obj : [.testsuite]bug-regex28.c \
	$(config_h) [.lib]regex.h

[.testsuite]tst-pcre.obj : [.testsuite]tst-pcre.c \
	$(config_h) [.lib]regex.h

[.testsuite]tst-boost.obj : [.testsuite]tst-boost.c \
	$(config_h) [.lib]regex.h

[.testsuite]tst-rxspencer.obj : [.testsuite]tst-rxspencer.c \
	$(config_h) [.lib]regex.h [.lib]getopt.h

[.testsuite]tst-regex2.obj : [.testsuite]tst-regex2.c \
	$(config_h) [.lib]regex.h

[.testsuite]runtests.obj : [.testsuite]runtests.c \
	$(config_h) [.lib]regex.h [.testsuite]testcases.h

[.testsuite]runptests.obj : [.testsuite]runptests.c \
	$(config_h) [.lib]regex.h [.testsuite]ptestcases.h


realclean : clean
    @ if f$search("config.h") .nes. "" then delete config.h;*
    @ if f$search("config_vms.h") .nes. "" then delete config_vms.h;*
    @ if f$search("gnv$sed.exe") .nes. "" then delete gnv$sed.exe;*
    @ if f$search("gnv$sed.dsf") .nes. "" then delete gnv$sed.dsf;*
    @ if f$search("gnv$sed.map") .nes. "" then delete gnv$sed.map;*
    @ if f$search("sed_debug.exe") .nes. "" then delete sed_debug.exe;*
    @ if f$search("sed_debug.dsf") .nes. "" then delete sed_debug.dsf;*
    @ if f$search("sed_debug.map") .nes. "" then delete sed_debug.map;*
    @ if f$search("sed_hack.exe") .nes. "" then delete sed_hack.exe;*
    @ if f$search("sed_hack.dsf") .nes. "" then delete sed_hack.dsf;*
    @ if f$search("sed_hack.map") .nes. "" then delete sed_hack.map;*
    @ if f$search("sed_hack_debug.exe") .nes. "" then \
	delete sed_hack_debug.exe;*
    @ if f$search("sed_hack_debug.dsf") .nes. "" then \
	delete sed_hack_debug.dsf;*
    @ if f$search("sed_hack_debug.map") .nes. "" then \
	delete sed_hack_debug.map;*
    @ if f$search("[.lib]getopt.h") .nes. "" then delete [.lib]getopt.h;*
    @ if f$search("[.lib]alloca.h") .nes. "" then delete [.lib]alloca.h;*
    @ if f$search("[.lib]stdint.h") .nes. "" then delete [.lib]stdint.h;*
    @ if f$search("[.lib.selinux]context.h") .nes. "" then \
	delete [.lib.selinux]context.h;*
    @ if f$search("[.lib.selinux]selinux.h") .nes. "" then \
	delete [.lib.selinux]selinux.h;*

clean :
    @ if f$search("sed.obj") .nes. "" then delete sed.obj;*
    @ if f$search("sed.lis") .nes. "" then delete sed.lis;*
    @ if f$search("sed_hack.obj") .nes. "" then delete sed_hack.obj;*
    @ if f$search("sed_hack.lis") .nes. "" then delete sed_hack.lis;*
    @ if f$search("compile.obj") .nes. "" then delete compile.obj;*
    @ if f$search("compile.lis") .nes. "" then delete compile.lis;*
    @ if f$search("execute.obj") .nes. "" then delete execute.obj;*
    @ if f$search("execute.lis") .nes. "" then delete execute.lis;*
    @ if f$search("regexp.obj") .nes. "" then delete regexp.obj;*
    @ if f$search("regexp.lis") .nes. "" then delete regexp.lis;*
    @ if f$search("fmt.obj") .nes. "" then delete fmt.obj;*
    @ if f$search("fmt.lis") .nes. "" then delete fmt.lis;*
    @ if f$search("mbcs.obj") .nes. "" then delete mbcs.obj;*
    @ if f$search("mbcs.lis") .nes. "" then delete mbcs.lis;*
    @ if f$search("utils.obj") .nes. "" then delete utils.obj;*
    @ if f$search("utils.lis") .nes. "" then delete utils.lis;*
    @ if f$search("utils_hack.obj") .nes. "" then delete utils_hack.obj;*
    @ if f$search("utils_hack.lis") .nes. "" then delete utils_hack.lis;*
    @ if f$search("vms_crtl_init.obj") .nes. "" then delete vms_crtl_init.obj;*
    @ if f$search("vms_crtl_init.lis") .nes. "" then delete vms_crtl_init.lis;*
    @ if f$search("[.lib]c-strcasecmp.obj") .nes. "" then \
		delete [.lib]c-strcasecmp.obj;*
    @ if f$search("c-strcasecmp.lis") .nes. "" then delete c-strcasecmp.lis;*
    @ if f$search("[.lib]c-ctype.obj") .nes. "" then delete [.lib]c-ctype.obj;*
    @ if f$search("c-ctype.lis") .nes. "" then delete c-ctype.lis;*
    @ if f$search("[.lib]copy-acl.obj") .nes. "" then \
	delete [.lib]copy-acl.obj;*
    @ if f$search("copy-acl.lis") .nes. "" then delete copy-acl.lis;*
    @ if f$search("[.lib]error.obj") .nes. "" then delete [.lib]error.obj;*
    @ if f$search("error.lis") .nes. "" then delete error.lis;*
    @ if f$search("[.lib]exitfail.obj") .nes. "" then \
	delete [.lib]exitfail.obj;*
    @ if f$search("exitfail.lis") .nes. "" then delete exitfail.lis;*
    @ if f$search("[.lib]getdelim.obj") .nes. "" then \
	delete [.lib]getdelim.obj;*
    @ if f$search("getdelim.lis") .nes. "" then delete getdelim.lis;*
    @ if f$search("[.lib]fwriting.obj") .nes. "" then delete [.lib]fwriting.obj;*
    @ if f$search("fwriting.lis") .nes. "" then delete fwriting.lis;*
    @ if f$search("[.lib]getopt.obj") .nes. "" then delete [.lib]getopt.obj;*
    @ if f$search("getopt.lis") .nes. "" then delete getopt.lis;*
    @ if f$search("[.lib]getopt1.obj") .nes. "" then delete [.lib]getopt1.obj;*
    @ if f$search("getopt1.lis") .nes. "" then delete getopt1.lis;*
    @ if f$search("[.lib]localcharset.obj") .nes. "" then \
		delete [.lib]localcharset.obj;*
    @ if f$search("localcharset.lis") .nes. "" then delete localcharset.lis;*
    @ if f$search("[.lib]mkostemp.obj") .nes. "" then delete [.lib]mkostemp.obj;*
    @ if f$search("mkostemp.lis") .nes. "" then delete mkostemp.lis;*
    @ if f$search("[.lib]obstack.obj") .nes. "" then delete [.lib]obstack.obj;*
    @ if f$search("obstack.lis") .nes. "" then delete obstack.lis;*
    @ if f$search("[.lib]quotearg.obj") .nes. "" then delete [.lib]quotearg.obj;*
    @ if f$search("quotearg.lis") .nes. "" then delete quotearg.lis;*
    @ if f$search("[.lib]regex.obj") .nes. "" then delete [.lib]regex.obj;*
    @ if f$search("regex.lis") .nes. "" then delete regex.lis;*
    @ if f$search("[.lib]set-mode-acl.obj") .nes. "" then \
		delete [.lib]set-mode-acl.obj;*
    @ if f$search("set-mode-acl.lis") .nes. "" then delete set-mode-acl.lis;*
    @ if f$search("[.lib]strverscmp.obj") .nes. "" then \
		delete [.lib]strverscmp.obj;*
    @ if f$search("strverscmp.lis") .nes. "" then delete strverscmp.lis;*
    @ if f$search("[.lib]tempname.obj") .nes. "" then \
		delete [.lib]tempname.obj;*
    @ if f$search("tempname.lis") .nes. "" then delete tempname.lis;*
    @ if f$search("[.lib]version-etc*.obj") .nes. "" then \
		delete [.lib]version-etc*.obj;*
    @ if f$search("version-etc*.lis") .nes. "" then delete version-etc*.lis;*
    @ if f$search("[.lib]xalloc-die.obj") .nes. "" then \
		delete [.lib]xalloc-die.obj;*
    @ if f$search("xalloc-die.lis") .nes. "" then delete xalloc-die.lis;*
    @ if f$search("[.lib]xmalloc.obj") .nes. "" then delete [.lib]xmalloc.obj;*
    @ if f$search("xmalloc.lis") .nes. "" then delete xmalloc.lis;*
    @ if f$search("[.lib]libsed.olb") .nes. "" then delete [.lib]libsed.olb;*
    @ if f$search("bug-regex*.exe") .nes. "" then delete bug-regex*.exe;*
    @ if f$search("bug-regex*.map") .nes. "" then delete bug-regex*.map;*
    @ if f$search("bug-regex*.dsf") .nes. "" then delete bug-regex*.dsf;*
    @ if f$search("bug-regex*.lis") .nes. "" then delete bug-regex*.lis;*
    @ if f$search("[.testsuite]bug-regex*.obj") .nes. "" then \
	delete [.testsuite]bug-regex*.obj;*
    @ if f$search("tst-pcre.exe") .nes. "" then delete tst-pcre.exe;*
    @ if f$search("tst-pcre.map") .nes. "" then delete tst-pcre.map;*
    @ if f$search("tst-pcre.dsf") .nes. "" then delete tst-pcre.dsf;*
    @ if f$search("tst-pcre.lis") .nes. "" then delete tst-pcre.lis;*
    @ if f$search("[.testsuite]tst-pcre.obj") .nes. "" then \
	delete [.testsuite]tst-pcre.obj;*
    @ if f$search("tst-boost.exe") .nes. "" then delete tst-boost.exe;*
    @ if f$search("tst-boost.map") .nes. "" then delete tst-boost.map;*
    @ if f$search("tst-boost.dsf") .nes. "" then delete tst-boost.dsf;*
    @ if f$search("tst-boost.lis") .nes. "" then delete tst-boost.lis;*
    @ if f$search("[.testsuite]tst-boost.obj") .nes. "" then \
	delete [.testsuite]tst-boost.obj;*
    @ if f$search("runtests.exe") .nes. "" then delete runtests.exe;*
    @ if f$search("runtests.map") .nes. "" then delete runtests.map;*
    @ if f$search("runtests.dsf") .nes. "" then delete runtests.dsf;*
    @ if f$search("runtests.lis") .nes. "" then delete runtests.lis;*
    @ if f$search("[.testsuite]runtests.obj") .nes. "" then \
	delete [.testsuite]runtests.obj;*
    @ if f$search("runptests.exe") .nes. "" then delete runptests.exe;*
    @ if f$search("runptests.map") .nes. "" then delete runptests.map;*
    @ if f$search("runptests.dsf") .nes. "" then delete runptests.dsf;*
    @ if f$search("runptests.lis") .nes. "" then delete runptests.lis;*
    @ if f$search("[.testsuite]runptests.obj") .nes. "" then \
	delete [.testsuite]runptests.obj;*
    @ if f$search("tst-rxspencer.exe") .nes. "" then delete tst-rxspencer.exe;*
    @ if f$search("tst-rxspencer.map") .nes. "" then delete tst-rxspencer.map;*
    @ if f$search("tst-rxspencer.dsf") .nes. "" then delete tst-rxspencer.dsf;*
    @ if f$search("tst-rxspencer.lis") .nes. "" then delete tst-rxspencer.lis;*
    @ if f$search("[.testsuite]tst-rxspencer.obj") .nes. "" then \
	delete [.testsuite]tst-rxspencer.obj;*
    @ if f$search("tst-regex2.exe") .nes. "" then delete tst-regex2.exe;*
    @ if f$search("tst-regex2.map") .nes. "" then delete tst-regex2.map;*
    @ if f$search("tst-regex2.dsf") .nes. "" then delete tst-regex2.dsf;*
    @ if f$search("tst-regex2.lis") .nes. "" then delete tst-regex2.lis;*
    @ if f$search("[.testsuite]tst-regex2.obj") .nes. "" then \
	delete [.testsuite]tst-regex2.obj;*
    @ if f$search("*sed*.pcsi$desc") .nes. "" then delete *sed*.pcsi$desc;*
    @ if f$search("*sed*.pcsi$text") .nes. "" then delete *sed*.pcsi$text;*
    @ if f$search("*sed*.release_notes") .nes. "" then \
	delete *sed*.release_notes;*

