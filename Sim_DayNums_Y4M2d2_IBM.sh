#! /usr/bin/bash

yr_s=2000
month_s=2 ; day_s=1  
month_e=3 ; day_e=20

function days_of_Month()
{
  year=$1
  month=$2
  days_mon=(31 28 31 30 31 30 31 31 30 31 30 31)
  Flag=`isleap $year`
  if [ $Flag -eq 0 ]
  then
       days_mon[1]=28
  else
       days_mon[1]=29
  fi
  ind=`expr $month - 1`
  echo ${days_mon[$ind]}
}

function isleap()
{
  year=$1
  if [ $[$year % 4] -eq 0 ] && [ $[$year % 100] -ne 0 ]
  then
       leap=1                    # echo "$year is a leap year"
  elif [ $[$year % 400] -eq 0 ]
  then
       leap=1                    # echo "$year is a leap year"
  else
       leap=0                    # echo "$year is not a leap year"
  fi
  echo $leap
}

# ========================================================================#
#          caculate the length of forecast days                           #
#  Notice: assume the begin-end date are in the same year                 #
# ========================================================================#
 
   # 1st, comput remain days at the begin and end month,separately
   days_mon_s=`days_of_Month $yr_s $month_s`
   remaind_mos=`expr ${days_mon_s} - ${day_s}`
   remaind_moe=$day_e
   unset days_mon_s

   #2nd, compute the forecast length
   if [ $month_s -eq $month_e ]
   then
        echo $month_s equals to $month_e
        fcst_days=`expr $day_e - $day_s`
   else
        echo $month_s not equals to $month_e
        fcst_days=`expr $remaind_mos + $remaind_moe`
        while [ $month_s -lt $[$month_e - 1] ]
        do
           days_mon_s=`days_of_Month $yr_s $month_s`
           fcst_days=`expr ${fcst_days} + ${days_mon_s}`
           ((month_s++))
        done
   fi
   
   echo $fcst_days
  exit
  
