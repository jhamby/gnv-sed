$! File: sed_testsuite.com
$!
$! Set default to [.testsuite]
$!
$! Input parameter is name of tests to run separated by commas.
$! Default is a list of test suites.
$!
$!======================================================================
$!
$ss_normal = 1
$ss_abort = 44
$status = ss_normal
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
$if f$locate(",help,", args_lower) .lt. args_len
$then
$   write sys$output "$ Set default [.testsuite]"
$   write sys$output "$ @[-.vms]sed_testsuite [""test1,test2""]"
$   write sys$output -
    "Pass a list of test names to run or blank to use the default list."
$   write sys$output -
    "The test names can be enclosed in quotes separated in commas"
$   write sys$output -
    "to get around the 8 parameter limit of DCL."
$   goto all_exit
$endif
$!
$ tst_cmp := "diff/Output=_NL:/Maximum=1"
$ sed := $sys$disk:[-]gnv$sed.exe
$!
$test_list1 = ",0range,8bit,8to7,allsub,amp-escape,appquit,badenc,binary"
$test_list2 = ",binary2,binary3,bkslashes,brackets,classes,cv-vars,dc"
$test_list3 = ",distrib,dollar,empty,enable,eval,factor,fasts,flipcase"
$test_list4 = ",head,inclib,insens,insert,khadafy,linecnt,mac-mf"
$test_list5 = ",madding,manis,middle,modulo,newjis,noeol,noeolw"
$test_list6 = ",numsub,numsub2,numsub3,numsub4,numsub5,readin,recall"
$test_list7 = ",recall2,sep,space,subwrite,uniq,utf8-1,utf8-2,utf8-3"
$test_list8 = ",utf8-4,writeout,xabcx,xbxcx,xbxcx3,xemacs,y-bracket"
$test_list9 = ",y-newline"
$!
$test_list = test_list1 + test_list2 + test_list3 + test_list4
$test_list = test_list + test_list5 + test_list6 + test_list7
$test_list = test_list + test_list8 + test_list9 + ","
$test_list_len = f$length(test_list)
$!
$if p1 .eqs. ""
$then
$   my_tests = test_list
$else
$   my_tests = args_lower
$endif
$!
$i = 0
$test_loop:
$   test = f$element(i, ",", my_tests)
$   if test .eqs. "," then goto test_loop_end
$   i = i + 1
$   if test .eqs. "" then goto test_loop
$   if f$locate(",''test',", test_list) .ge. test_list_len
$   then
$      write sys$output "Test ''test' does not exist!"
$      goto test_loop
$   endif
$   test_label = "tst_" + test - "-"
$   gosub 'test_label'
$   goto test_loop
$test_loop_end:
$!
$all_exit:
$exit 'status'
$!
$! On error, bail
$bad_exit:
$status = $status
$if status .and. 1 then status = ss_abort
$goto all_exit
$!
$!
$tst_0range:
$tst_8bit:
$tst_8to7:
$tst_allsub:
$tst_ampescape:
$tst_appquit:
$tst_badenc:
$tst_binary:
$tst_bkslashes:
$tst_brackets:
$tst_classes:
$tst_cvvars:
$tst_dc:
$tst_distrib:
$tst_dollar:
$tst_empty:
$tst_enable:
$tst_eval:
$tst_factor:
$tst_fasts:
$tst_flipcase:
$tst_head:
$tst_inclib:
$tst_insens:
$tst_insert:
$tst_khadafy:
$tst_linecnt:
$tst_macmf:
$tst_madding:
$tst_manis:
$tst_middle:
$tst_modulo:
$tst_newjis:
$tst_noeol:
$tst_numsub:
$tst_numsub2:
$tst_numsub3:
$tst_numsub4:
$tst_numsub5:
$tst_readin:
$tst_recall:
$tst_recall2:
$tst_sep:
$tst_space:
$tst_subwrite:
$tst_uniq:
$tst_utf81:
$tst_utf82:
$tst_utf83:
$tst_utf84:
$tst_writeout:
$tst_xabcx:
$tst_xbxcx:
$tst_xbxcx3:
$tst_xemacs:
$tst_ybracket:
$tst_ynewline:
$   write sys$output  "''test'"
$   out_file = "sys$disk:[]_''test'.tmp"
$   if f$search(out_file) .nes. "" then delete 'out_file';*
$   in_file = "''test'.inp"
$   good_file = "''test'.good"
$test_common:
$   define/user sys$output 'out_file';
$   sed -f 'test'.sed 'in_file'
$   status = '$status'
$   unix_status = (status .and. %x7f8) / 8
$   if unix_status .eq. 1
$   then
$       tst_cmp 'good_file' 'out_file'
$       status = '$status'
$       if ((status .and. 1) .eq. 1)
$       then
$           write sys$output "''test' pass."
$	    delete 'out_file';*
$           if f$search("''test'.%out") .nes. "" then delete 'test'.%out;*
$       else
$           write sys$output -
            "''test' failed in compare ''good_file' and ''out_file'!"
$       endif
$   endif
$   if (unix_status .ne. 0)
$   then
$       write sys$output "''test' failed with exit code ''unix_status'!"
$   endif
$return
$!
$tst_binary2:
$tst_binary3:
$   write sys$output "''test'"
$   out_file = "sys$disk:[]_''test'.tmp"
$   if f$search(out_file) .nes. "" then delete 'out_file';*
$   in_file = "binary.inp"
$   good_file = "binary.good"
$   goto test_common
$!
$tst_noeolw:
$   write sys$output "''test' skipped."
$   out_file = "sys$disk:[]_''test'.tmp"
$   if f$search(out_file) .nes. "" then delete 'out_file';*
$return
$!
$!
