$! File: remove_old_sed.com
$!
$! This is a procedure to remove the old sed images that were installed
$! by the GNV kits and replace them with links to the new image.
$!
$! 24-Jan-2014  J. Malmberg	Sed version
$!
$!==========================================================================
$!
$vax = f$getsyi("HW_MODEL") .lt. 1024
$old_parse = ""
$if .not. VAX
$then
$   old_parse = f$getjpi("", "parse_style_perm")
$   set process/parse=extended
$endif
$!
$old_cutils = "sed"
$!
$!
$ i = 0
$cutils_loop:
$   file = f$element(i, ",", old_cutils)
$   if file .eqs. "" then goto cutils_loop_end
$   if file .eqs. "," then goto cutils_loop_end
$   call update_old_image 'file'
$   i = i + 1
$   goto cutils_loop
$cutils_loop_end:
$!
$!
$if .not. VAX
$then
$   file = "gnv$gnu:[usr.share.man.cat1]sed^.1.gz"
$   if f$search(file) .nes. "" then delete 'file';*
$endif
$!
$!
$if .not. VAX
$then
$   set process/parse='old_parse'
$endif
$!
$all_exit:
$  exit
$!
$! Remove old image or update it if needed.
$!-------------------------------------------
$update_old_image: subroutine
$!
$ file = p1
$! First get the FID of the new sed image.
$! Don't remove anything that matches it.
$ new_sed = f$search("GNV$GNU:[BIN]GNV$''file'.EXE")
$!
$ new_sed_fid = "No_new_sed_fid"
$ if new_sed .nes. ""
$ then
$   new_sed_fid = f$file_attributes(new_sed, "FID")
$ endif
$!
$!
$!
$! Now get check the "''file'." and "''file'.exe"
$! May be links or copies.
$! Ok to delete and replace.
$!
$!
$ old_sed_fid = "No_old_sed_fid"
$ old_sed = f$search("gnv$gnu:[bin]''file'.")
$ old_sed_exe_fid = "No_old_sed_fid"
$ old_sed_exe = f$search("gnv$gnu:[bin]''file'.exe")
$ if old_sed_exe .nes. ""
$ then
$   old_sed_exe_fid = f$file_attributes(old_sed_exe, "FID")
$ endif
$!
$ if old_sed .nes. ""
$ then
$   fid = f$file_attributes(old_sed, "FID")
$   if fid .nes. new_sed_fid
$   then
$       if fid .eqs. old_sed_exe_fid
$       then
$           set file/remove 'old_sed'
$       else
$           delete 'old_sed'
$       endif
$       if new_sed .nes. ""
$       then
$           set file/enter='old_sed' 'new_sed'
$       endif
$   endif
$ endif
$!
$ if old_sed_exe .nes. ""
$ then
$   if old_sed_fid .nes. new_sed_fid
$   then
$       delete 'old_sed_exe'
$       if new_sed .nes. ""
$       then
$           set file/enter='old_sed_exe' 'new_sed'
$       endif
$   endif
$ endif
$!
$ exit
$ENDSUBROUTINE ! Update old image
$! File: remove_old_sed.com
$!
$! This is a procedure to remove the old sed images that were installed
$! by the GNV kits and replace them with links to the new image.
$!
$! 02-Jan-2014  J. Malmberg	Sed version
$!
$!==========================================================================
$!
$vax = f$getsyi("HW_MODEL") .lt. 1024
$old_parse = ""
$if .not. VAX
$then
$   old_parse = f$getjpi("", "parse_style_perm")
$   set process/parse=extended
$endif
$!
$old_cutils = "sed"
$!
$!
$ i = 0
$cutils_loop:
$   file = f$element(i, ",", old_cutils)
$   if file .eqs. "" then goto cutils_loop_end
$   if file .eqs. "," then goto cutils_loop_end
$   call update_old_image 'file'
$   i = i + 1
$   goto cutils_loop
$cutils_loop_end:
$!
$!
$if .not. VAX
$then
$   file = "gnv$gnu:[usr.share.man.cat1]sed^.1.gz"
$   if f$search(file) .nes. "" then delete 'file';*
$endif
$!
$!
$if .not. VAX
$then
$   set process/parse='old_parse'
$endif
$!
$all_exit:
$  exit
$!
$! Remove old image or update it if needed.
$!-------------------------------------------
$update_old_image: subroutine
$!
$ file = p1
$! First get the FID of the new sed image.
$! Don't remove anything that matches it.
$ new_sed = f$search("GNV$GNU:[BIN]GNV$''file'.EXE")
$!
$ new_sed_fid = "No_new_sed_fid"
$ if new_sed .nes. ""
$ then
$   new_sed_fid = f$file_attributes(new_sed, "FID")
$ endif
$!
$!
$!
$! Now get check the "''file'." and "''file'.exe"
$! May be links or copies.
$! Ok to delete and replace.
$!
$!
$ old_sed_fid = "No_old_sed_fid"
$ old_sed = f$search("gnv$gnu:[bin]''file'.")
$ old_sed_exe_fid = "No_old_sed_fid"
$ old_sed_exe = f$search("gnv$gnu:[bin]''file'.exe")
$ if old_sed_exe .nes. ""
$ then
$   old_sed_exe_fid = f$file_attributes(old_sed_exe, "FID")
$ endif
$!
$ if old_sed .nes. ""
$ then
$   fid = f$file_attributes(old_sed, "FID")
$   if fid .nes. new_sed_fid
$   then
$       if fid .eqs. old_sed_exe_fid
$       then
$           set file/remove 'old_sed'
$       else
$           delete 'old_sed'
$       endif
$       if new_sed .nes. ""
$       then
$           set file/enter='old_sed' 'new_sed'
$       endif
$   endif
$ endif
$!
$ if old_sed_exe .nes. ""
$ then
$   if old_sed_fid .nes. new_sed_fid
$   then
$       delete 'old_sed_exe'
$       if new_sed .nes. ""
$       then
$           set file/enter='old_sed_exe' 'new_sed'
$       endif
$   endif
$ endif
$!
$ exit
$ENDSUBROUTINE ! Update old image
