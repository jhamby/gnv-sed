$! File: pcsi_product_sed.com
$!
$! This command file packages up the product SED into a sequential
$! format kit
$!
$! If P1 is "BETA" then the kit version type is forced to start with
$! a "B" instead of its normal letter.  If P2 is also specified, then
$! the first character of P2 will be used for the version.
$!
$! If P1 is "COMPRESSED", an additional compressed kit is produced.
$! This compressed kit is not as small as ZIP compression can do.
$! COMPRESSED and BETA are mutually exclusive.
$!
$! 13-Dec-2013  J.Malmberg
$!
$!=========================================================================
$!
$! Save default
$ default_dir = f$environment("DEFAULT")
$!
$! Put things back on error.
$ on warning then goto all_exit
$!
$ arch_type = f$getsyi("ARCH_NAME")
$ arch_code = f$extract(0, 1, arch_type)
$!
$ can_build = 1
$ producer = f$trnlnm("GNV_PCSI_PRODUCER")
$ if producer .eqs. ""
$ then
$   write sys$output "GNV_PCSI_PRODUCER logical name has not been set."
$   can_build = 0
$ endif
$ producer_full_name = f$trnlnm("GNV_PCSI_PRODUCER_FULL_NAME")
$ if producer_full_name .eqs. ""
$ then
$   write sys$output -
        "GNV_PCSI_PRODUCER_FULL_NAME logical name has not been set."
$   can_build = 0
$ endif
$ stage_root_name = f$trnlnm("STAGE_ROOT")
$ if stage_root_name .eqs. ""
$ then
$   write sys$output "STAGE_ROOT logical name has not been set."
$   can_build = 0
$ endif
$!
$ if (can_build .eq. 0)
$ then
$   write sys$output "Not able to build a kit."
$   goto all_exit
$ endif
$!
$!
$! Build the sed image(s)
$!-------------------------
$ if f$search("gnv$sed.exe") .eqs. ""
$ then
$   mmk/descrip=[.vms]sed.mms
$ endif
$!
$! Stage the images for building the kit
$!--------------------------------------
$ @[.vms]stage_sed_install.com remove
$ @[.vms]stage_sed_install.com
$!
$!
$!
$! Make sure that the kit name is up to date for this build
$!----------------------------------------------------------
$ @[.vms]make_pcsi_sed_kit_name.com 'p1' 'p2'
$!
$! Make sure that the release note file name is up to date
$!---------------------------------------------------------
$ @[.vms]build_sed_release_notes.com
$!
$!
$! Make sure that the source has been backed up.
$!----------------------------------------------
$ @[.vms]backup_sed_src.com
$!
$! Regenerate the PCSI description file.
$!--------------------------------------
$ @[.vms]build_sed_pcsi_desc.com
$!
$! Regenerate the PCSI Text file.
$!---------------------------------
$ @[.vms]build_sed_pcsi_text.com
$!
$ base = ""
$ arch_name = f$edit(f$getsyi("arch_name"),"UPCASE")
$ if arch_name .eqs. "ALPHA" then base = "AXPVMS"
$ if arch_name .eqs. "IA64" then base = "I64VMS"
$ if arch_name .eqs. "VAX" then base = "VAXVMS"
$!
$! Parse the kit name into components.
$!---------------------------------------
$ kit_name = f$trnlnm("GNV_PCSI_KITNAME")
$ if kit_name .eqs. ""
$ then
$   write sys$output "@[.vms]make_pcsi_sed_kit_name.com has not been run."
$   goto all_exit
$ endif
$ producer = f$element(0, "-", kit_name)
$ base = f$element(1, "-", kit_name)
$ product_name = f$element(2, "-", kit_name)
$ mmversion = f$element(3, "-", kit_name)
$ majorver = f$extract(0, 3, mmversion)
$ minorver = f$extract(3, 2, mmversion)
$ updatepatch = f$element(4, "-", kit_name)
$ if updatepatch .eqs. "" then updatepatch = ""
$!
$ version_fao = "!AS.!AS"
$ if arch_name .eqs. "VAX" then version_fao = "!AS$5n!AS"
$ mmversion = f$fao(version_fao, "''majorver'", "''minorver'")
$ if updatepatch .nes. ""
$ then
$   version = "''mmversion'" + "-" + updatepatch
$ else
$   version = "''mmversion'"
$ endif
$!
$ node_swvers = f$getsyi("node_swvers")
$ vms_vernum = f$extract(1, f$length(node_swvers), node_swvers)
$ tagver = vms_vernum - "." - "." - "-"
$ zip_name = producer + "-" + base + "-" + tagver + "-" + product_name
$ zip_name = zip_name + "-" + mmversion + "-" + updatepatch + "-1"
$ zip_name = f$edit(zip_name, "lowercase")
$!
$! Move to the base directories
$ current_default = f$environment("DEFAULT")
$ my_dir = f$parse(current_default,,,"DIRECTORY") - "[" - "<" - ">" - "]"
$!
$!
$ source = "''default_dir'"
$ src1 = "new_gnu:[bin],"
$ src2 = "new_gnu:[usr.bin],"
$ src3 = "new_gnu:[vms_bin],"
$ src4 = "new_gnu:[vms_src],"
$ src5 = "new_gnu:[common_src],"
$ src6 = "sys$disk:[''my_dir'],sys$disk:[''my_dir'.vms],"
$ src7 = "new_gnu:[usr.share.sed],"
$ src8 = "new_gnu:[usr.share.man.man1],"
$ src9 = "new_gnu:[usr.share.doc.sed],"
$ src10 = "new_gnu:[usr.share.info]"
$ gnu_src = src1 + src2 + src3 + src4 + src5 + src6 + src7 + src8 + src9
$ gnu_src = gnu_src + src10
$!
$!
$ if base .eqs. "" then exit 44
$!
$ pcsi_option = "/option=noconfirm"
$ if arch_code .eqs. "V"
$ then
$   pcsi_option = ""
$ endif
$!
$!
$product package 'product_name' -
 /base='base' -
 /producer='producer' -
 /source='source' -
 /destination=STAGE_ROOT:[KIT] -
 /material=('gnu_src','source') -
 /format=sequential 'pcsi_option'
$!
$!
$if f$type(zip) .eqs. "STRING"
$then
$   zip "-9Vj" stage_root:[kit]'zip_name'.zip stage_root:[kit]'kit_name'.pcsi
$endif
$!
$all_exit:
$ set def 'default_dir'
$ exit
