$! File: build_sed_release_notes.com
$!
$! Build the release note file from the three components:
$!    1. The sed_release_note_start.txt
$!    2. readme. file from the Sed distribution.
$!    3. The sed_build_steps.txt.
$!
$! Set the name of the release notes from the GNV_PCSI_FILENAME_BASE
$! logical name.
$!
$!
$! 24-Jan-2014  J. Malmberg
$!
$!===========================================================================
$!
$ base_file = f$trnlnm("GNV_PCSI_FILENAME_BASE")
$ if base_file .eqs. ""
$ then
$   write sys$output "@make_pcsi_sed_kit_name.com has not been run."
$   goto all_exit
$ endif
$!
$!
$ sed_readme = f$search("sys$disk:[]readme.")
$ if sed_readme .eqs. ""
$ then
$   sed_readme = f$search("sys$disk:[]$README.")
$ endif
$ if sed_readme .eqs. ""
$ then
$   write sys$output "Can not find sed readme file."
$   goto all_exit
$ endif
$!
$ sed_copying = f$search("sys$disk:[]copying.")
$ if sed_copying .eqs. ""
$ then
$   sed_copying = f$search("sys$disk:[]$COPYING.")
$ endif
$ if sed_copying .eqs. ""
$ then
$   write sys$output "Can not find sed copying file."
$   goto all_exit
$ endif
$!
$ type/noheader sys$disk:[.vms]sed_release_note_start.txt,-
        'sed_readme',-
        'sed_copying', -
        sys$disk:[.vms]sed_build_steps.txt -
        /out='base_file'.release_notes
$!
$ purge 'base_file'.release_notes
$ rename 'base_file.release_notes ;1
$!
$all_exit:
$   exit
