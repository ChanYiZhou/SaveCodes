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

   # 1st, comput remain days at the begin and end year,separately
   daysId=`day_in_year $yr_s $month_s $day_s`
   dayeId=`day_in_year $yr_e $month_e $day_e`
   Flags=`isleap $yr_s`
   if [ $Flags -eq 1 ]
   then
       remaind_yrs=`expr 366 - $daysId`
   else
       remaind_yrs=`expr 365 - $daysId`
   fi 
   remaind_yre=$dayeId

   #2nd, compute the forecast length
   if [ $yr_s -eq $yr_e ]
   then
       echo $yr_s equals to $yr_e
       if [ $month_s -eq $month_e ]
       then
            echo $month_s equals to $month_e
            fcst_days=`expr $day_e - $day_s`
       else
            echo $month_s not equals to $month_e
            fcst_days=`expr $dayeId - $daysId`
       fi
   else
       echo $yr_s not equals to $yr_e 
       fcst_days=`expr $remaind_yrs + $remaind_yre`
       iyr=$yr_s
       while [ $iyr -lt $[$yr_e - 1] ]
       do
          iFlag=`isleap $iyr`
          if [ $iFlag -eq 0 ]
          then
              fcst_days=`expr $fcst_days + 365`
          else
              fcst_days=`expr $fcst_days + 366`
          fi
         ((iyr++))
       done
   fi
   
   
   echo $fcst_days
