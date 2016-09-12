#! /usr/bin/csh

 #===============================================================================#
 # Accomplish work:                                                              #
 #   finish post process-figures plotting of WRF model by using NCL .         #   
 #                                                                               #
 #-------------------------------------------------------------------------------#
 # Author: Zhoujunqian             Email: zhoujunqian12@mails.ucas.ac.cn         #
 # QQ:804630256                    phone: (+86) 010-58993413                     #
 # Creat date: 2016-03-22          Modify date:                                  #
 #                                                                               #
 #===============================================================================#
  
  echo "Postprocess scripts  start running Date: "
  date +%Y-%m-%d_%H:%M:%S
  echo ""
  echo "---------------------------------------- "
  echo " "
  
  #====== set global environmental variables ======#
  setenv  CaseNam r151001_151008
  setenv  dateStr 2015-10-01
  setenv  domain  1
  setenv  InROOT  /cma/u/Twangzzh/g4/Business/RME/3.6_script/WRF3.6/ 
  setenv  InPath  ${InROOT}${CaseNam}/output/data/
  setenv  OutPath  ${InROOT}${CaseNam}/output/figs/
  setenv  postsrc  ${InROOT}post/
  
  #==== get indata filename string ====#
  set inflStr0="wrfout_d0${domain}_${dateStr}"
  set inflNam=`cd ${InPath}; ls ${inflStr0}*`
  setenv Infls ${inflNam}
  echo "Input filename : "${Infls}
 
  #=== check input and output path ====#
   foreach dir ( ${InPath} ${OutPath} )
       if !(-d ${dir}) then
           echo "make path: "${dir}
           mkdir -p ${dir}
       endif
   end
 


  #======= involks ncl srcipts to plot figures =====#
  cd ${postsrc}
 # ncl wrf_Cloud.ncl
  foreach src (`ls  *.ncl`)
    echo "Involks ncl script: "${src}
    ncl ${src} 
  end
    
   
