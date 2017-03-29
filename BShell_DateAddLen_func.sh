#! /bin/bash

 #== function DateAddLen()
   function DateAddLen()
  {
    # the external argvs
    Sdate=$1
    len=$2
    yr_s=`echo $Sdate | cut -c 1-4`
    mon_s=`echo $Sdate | cut -c 5-6`
    day_s=`echo $Sdate | cut -c 7-8`
    #== days in twelve months of one not leap year
    days_of_mon=(31 28 31 30 31 30 31 31 30 31 30 31)
    #== calculate the end date
    yr_e=$yr_s
    mon_e=$mon_s
    day_e=$day_s
    ilen=1
    while [ $ilen -le $len ]
    do   
       yr_eleap=`isleap $yr_e`
       if [ $yr_eleap -eq 1 ]
       then
            days_of_mon[1]=29
       fi
       day_e=`expr $day_e + 1`
       ine=`expr $mon_e - 1`
       if [ $day_e -gt ${days_of_mon[$ine]} ] 
       then
            day_e=01
            mon_e=`expr $mon_e + 1`
            if [ $mon_e -gt 12 ] 
            then
                 mon_e=01
                 yr_e=`expr $yr_e + 1`
            fi
        fi
        ((ilen++))
     done
     
     dateAdjust=($mon_e $day_e) 
     numdate=${#dateAdjust[@]}
     idate=1
     while [ $idate -le $numdate ]     
     do     
         indat=`expr $idate - 1`
         if [ ${#dateAdjust[$indat]} -lt 2 ]
         then
              dateAdjust[$indat]=0${dateAdjust[$indat]}
         fi
         ((idate++))
     done
     Edate=${yr_e}${dateAdjust[0]}${dateAdjust[1]}
     # Edate=${yr_e}${mon_e}${day_e}
     echo $Edate
  }