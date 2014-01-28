$! File: GENERATE_CONFIG_H_VMS_SED.COM
$!
$! Sed like most open source products uses a variant of a config.h file.
$! Depending on the curl version, this could be config.h or curl_config.h.
$!
$! For GNV based builds, the configure script is run and that produces
$! a [curl_]config.h file.  Configure scripts on VMS generally do not
$! know how to do everything, so there is also a [-.lib]config-vms.h file
$! that has VMS specific code that compensates for bugs in some of the
$! VMS shared images.
$!
$! This generates a []config.h file and also a config_vms.h file,
$! which is used to supplement that file.
$!
$!
$! Copyright 2013, John Malmberg
$!
$! Permission to use, copy, modify, and/or distribute this software for any
$! purpose with or without fee is hereby granted, provided that the above
$! copyright notice and this permission notice appear in all copies.
$!
$! THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
$! WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
$! MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
$! ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
$! WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
$! ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
$! OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
$!
$!
$! 28-Nov-2013	J. Malmberg
$!
$!=========================================================================
$!
$! Allow arguments to be grouped together with comma or separated by spaces
$! Do no know if we will need more than 8.
$ args = "," + p1 + "," + p2 + "," + p3 + "," + p4 + ","
$ args = args + p5 + "," + p6 + "," + p7 + "," + p8 + ","
$!
$! Provide lower case version to simplify parsing.
$ args_lower = f$edit(args, "LOWERCASE")
$!
$ args_len = f$length(args)
$!
$ if (f$getsyi("HW_MODEL") .lt. 1024)
$ then
$   arch_name = "VAX"
$ else
$   arch_name = ""
$   arch_name = arch_name + f$edit(f$getsyi("ARCH_NAME"), "UPCASE")
$   if (arch_name .eqs. "") then arch_name = "UNK"
$ endif
$!
$!
$! HAVE_RAW_* not used by VMS build
$!
$!
$!
$! Start the configuration file.
$! Need to do a create and then an append to make the file have the
$! typical file attributes of a VMS text file.
$ create sys$disk:[]config_vms.h
$ open/append cvh sys$disk:[]config_vms.h
$!
$! Write the defines to prevent multiple includes.
$! These are probably not needed in this case,
$! but are best practice to put on all header files.
$ write cvh "#ifndef __CONFIG_VMS_H__"
$ write cvh "#define __CONFIG_VMS_H__"
$ write cvh ""
$!
$ write cvh "#include ""vms_sed_hacks.h"""
$ write cvh ""
$!
$! Close out the file
$!
$ write cvh ""
$ write cvh "#endif /* __CONFIG_VMS_H__ */"
$ close cvh
$!
$all_exit:
$ exit
