#! /usr/bin/bash

yr_s=2015 ; month_s=6 ; day_s=1
yr_e=2015 ; month_e=8 ; day_e=31

function day_in_year()
{
  year=$1
  month=$2
  day=$3
  pid=$day
  imo=1
  while [ $imo -lt $month ]
  do
     days_of_month=`days_of_Month $year $imo`
     pid=`expr $pid + $days_of_month`
     ((imo++))
  done
  echo $pid
}

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
# ========================================================================#
 
 # 1st, comput remain days at the begin and end month,separately
   days_mon_s=`days_of_Month $yr_s $month_s`
   remaind_mos=`expr ${days_mon_s} - ${day_s}`
   remaind_moe=$day_e
   unset days_mon_s
 
   # 2nd, comput remain days at the begin and end year,separately
   imos=$month_s
   imoe=1
   remaind_yrs=$remaind_mos
   remaind_yre=$remaind_moe
   while [ $imos -lt 12 ]
   do
      days_mon_s=`days_of_Month $yr_s $imos`
      remaind_yrs=`expr $remaind_yrs + ${days_mon_s}`
      ((imos++))
   done
   while [ $imoe -lt $month_e ]
   do
      days_mon_e=`days_of_Month $yr_e $imoe`
      remaind_yre=`expr $remaind_yre + ${days_mon_e}`
      ((imoe++))
   done
   unset days_mon_s
   
   #3rd, compute the forecast length
   if [ $yr_s -eq $yr_e ]
   then
       echo $yr_s equals to $yr_e
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
   else
       echo $yr_s not equals to $yr_e 
       fcst_days=`expr $remaind_yrs + $remaind_yre`
       while [ $yr_s -lt $[$yr_e - 1] ]
       do
          Flags=`isleap $yr_s`
          if [ $Flags -eq 0 ]
          then
              fcst_days=`expr $fcst_days + 365`
          else
              fcst_days=`expr $fcst_days + 366`
          fi
         ((yr_s++))
       done
   fi
   
   
   echo $fcst_days
