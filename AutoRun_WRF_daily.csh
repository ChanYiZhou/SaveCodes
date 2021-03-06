#!/bin/csh -f

# 预报的总时长simulen
set simulen = 29 
# 初次预报的开始日期simu_SD(%Y%m%d)
set simu_SD = "20100402"
# 一次预报的时效fcstlen, 单位为day或者hour
set fcstlen = 30
# 每次预报的开始时间
set fcst_SH = (02) #(02 14)
set CurrentPath = `pwd`


@ n = 0 
while( ${n} < ${simulen} )
	echo "$n"
	foreach ihour (${fcst_SH[*]})
		set fcst_SD = `date +%Y%m%d -d "${simu_SD} ${n} days"`
                echo ${fcst_SD}  ${ihour}  ${fcstlen}                 
				echo "--------------------------------------------------"
				echo " $rundate$runhour wrf work has been beginning to do!"
				echo "--------------------------------------------------"
                # ${CurrentPath}/run_wps_daily.csh ${fcst_SD} ${ihour} ${fcstlen} ${simulen}
                # if ( $? == 0 ) then
	            ${CurrentPath}/run_wrf_YN.csh ${fcst_SD} ${ihour} ${fcstlen} ${simulen}
                # endif

	end
	echo " "
	echo " "
	echo "sleep 1 minute"
	sleep 60
	@ n++
end

exit 0
