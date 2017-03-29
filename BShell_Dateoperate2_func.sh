#! /usr/bin/bash


# Define one function used to get the day position in one secify year
#= notice:                                                         =#
#=      argv format:Y4,MM,dd                                       =#
#===================================================================# 
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


# Define one function used to get the day number in one secify month
#= notice:                                                         =#
#=      argv format:Y4,MM                                          =#
#===================================================================# 
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

# Define one function decide whether the given year is a leap year
#= notice:                                                         =#
#=      argv format:Y4                                             =#
#===================================================================# 
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

result=`day_in_year 2013 12 31`
echo "result is: "$result

exit
