#!/usr/bin/csh -f

#set verbose

set rdate = $argv[1] # yyyymmdd
set runhour = $argv[2] # 02 or 14
set periods = $argv[3] # forecaset hour length
set simulen = $argv[4] # total simulate day length

set WRFROOT = /gza/g5/fengdx/WRF2
set WRFDIR = ${WRFROOT}/WRFV3/run
set METDIR = ${WRFROOT}/WPS
set WRFOUTDIR = ${WRFROOT}/Outputs/HB_${simulen}days

if ( $runhour == 02 ) then
  set rundate = `date +%Y%m%d -d "1 days ago $rdate"`
  set utchour = 18
else if ( $runhour == 14 ) then
  set rundate = $rdate
  set utchour = 6
else
  echo "Error args for run hour (02 or 14), exit."
  exit 1
endif

set sdate = `date +%Y%m%d%H -d "$rundate $utchour hours"`
set edate = `date +%Y%m%d%H -d "$rundate $utchour hours $periods hours"`

set syyyy = `echo $sdate | cut -c 1-4`
set smm   = `echo $sdate | cut -c 5-6`
set sdd   = `echo $sdate | cut -c 7-8`
set shh   = `echo $sdate | cut -c 9-10`

set eyyyy = `echo $edate | cut -c 1-4`
set emm   = `echo $edate | cut -c 5-6`
set edd   = `echo $edate | cut -c 7-8`
set ehh   = `echo $edate | cut -c 9-10`

if ( ! -d $WRFOUTDIR/$rundate$runhour ) mkdir -p $WRFOUTDIR/$rundate$utchour

cd $WRFDIR

cat > namelist.input <<EOF
&time_control            
run_days                 = 0,
run_hours                = ${periods},
run_minutes              = 0,
run_seconds              = 0,
start_year               = ${syyyy}, ${syyyy}, ${syyyy}, ${syyyy},
start_month              = ${smm}, ${smm}, ${smm}, ${smm},
start_day                = ${sdd}, ${sdd}, ${sdd}, ${sdd},
start_hour               = ${shh}, ${shh}, ${shh}, ${shh},
start_minute             = 00, 00, 00, 00,
start_second             = 00, 00, 00, 00,
end_year                 = ${eyyyy}, ${eyyyy}, ${eyyyy}, ${eyyyy},
end_month                = ${emm}, ${emm}, ${emm}, ${emm},
end_day                  = ${edd}, ${edd}, ${edd}, ${edd},
end_hour                 = ${ehh}, ${ehh}, ${ehh}, ${ehh},
end_minute               = 00, 00, 00, 00,
end_second               = 00, 00, 00, 00,
interval_seconds         = 21600,
input_from_file          = .true., .true., .true., .true.,
history_interval         = 60, 60, 30, 15,
frames_per_outfile       = 10000, 10000, 10000, 1
cycling                             = .true.
restart                             = .false.,
restart_interval                    = 5000,
io_form_history                     = 2
io_form_restart                     = 2
io_form_input                       = 2
io_form_boundary                    = 2
debug_level                         = 0
write_input                         = .true.,
inputout_interval                   = 180, 180, 180, 180
input_outname                       = "wrfinput_d<domain>_<date>"
io_form_auxinput4                   = 2
auxinput4_inname                    = "wrflowinp_d<domain>"
auxinput4_interval                  = 180, 180, 180, 180
 /

&domains
 time_step                           = 6,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = 4,
 e_we                                = 100,    88,    76,   64,
 e_sn                                = 132,    118,   106,  94,
 e_vert                              = 58,     58,     58,  58,
 p_top_requested                     = 1000,
 num_metgrid_levels                  = 61,
 num_metgrid_soil_levels             = 4,
 dx                                  = 27000, 9000,  3000,  1000,
 dy                                  = 27000, 9000,  3000,  1000,
 grid_id                             = 1,     2,     3,   4,
 parent_id                           = 0,     1,     2,   3,
 i_parent_start                      = 1,    36,    32,   28,
 j_parent_start                      = 1,    47,    42,   38,
 parent_grid_ratio                   = 1,     3,     3,   3,
 parent_time_step_ratio              = 1,     3,     3,   3,
 feedback                            = 1,
 smooth_option                       = 0
 eta_levels   = 1.000, 0.998, 0.996, 0.994, 0.992,
                0.990, 0.988, 0.985, 0.982, 0.979,
                0.976, 0.973, 0.971, 0.968, 0.964,
                0.956, 0.948, 0.940, 0.932, 0.924,
                0.916, 0.908, 0.899, 0.879, 0.859,
                0.829, 0.799, 0.769, 0.739, 0.708,
                0.678, 0.648, 0.618, 0.588, 0.558,
                0.528, 0.498, 0.468, 0.438, 0.408,
                0.378, 0.348, 0.318, 0.288, 0.258,
                0.228, 0.198, 0.170, 0.145, 0.125,
                0.105, 0.0855, 0.0713, 0.0571,
                0.0287, 0.0145, 0.009, 0.000
 /


 &physics
 mp_physics                          = 6,     6,     6,    6,
 ra_lw_physics                       = 1,     1,     1,    1,
 ra_sw_physics                       = 1,     1,     1,    1,
 radt                                = 30,    30,    30,   30,  
 sf_sfclay_physics                   = 1,     1,     1,    1,
 sf_surface_physics                  = 2,     2,     2,    2,
 bl_pbl_physics                      = 7,     7,     7,    0,
 bldt                                = 0,     0,     0,    0,
 cu_physics                          = 1,     1,     0,    0
 cudt                                = 5,     5,     5,    5,
 isfflx                              = 1,
 ifsnow                              = 1,
 icloud                              = 1,
 surface_input_source                = 1,
 num_soil_layers                     = 4,
 num_land_cat                        = 24
 sf_urban_physics                    = 0,     0,     0,
 sst_update                          = 1 
 /

 &fdda
 grid_fdda                           =  0,     0,   0,  0
 gfdda_inname                        = "wrffdda_d<domain>"
 gfdda_interval_m                    = 180, 180, 180, 180
 gfdda_end_h                         = 3,     3,  3,  3 
 fgdt                                = 0,     0,  0,  0
 if_no_pbl_nudging_uv                = 1,     1,  1,  1
 if_no_pbl_nudging_t                 = 1,     1,  1,  1
 if_no_pbl_nudging_q                 = 1,     1,  1,  1
 if_zfac_uv                          = 0,     0,  0,  0
  k_zfac_uv                          = 10,   10,  10, 10
 if_zfac_t                           = 0,     0,  0,  0
  k_zfac_t                           = 10,   10,  10, 10
 if_zfac_q                           = 0,     0,  0,  0
  k_zfac_q                           = 0,     0,  0,  0
 guv                                 = 0.0003,0.0003, 0.0003, 0.0003
 gt                                  = 0.0003,0.0003, 0.0003, 0.0003
 gq                                  = 0.0003,0.0003, 0.0003, 0.0003
 if_ramping                          = 1,
 dtramp_min                          = 60.0,
 io_form_gfdda                       = 2,
 /

 &dynamics
 w_damping                           = 0,
 diff_opt                            = 1,
 km_opt                              = 4,
 diff_6th_opt                        = 0,      0,      0,    0,
 diff_6th_factor                     = 0.12,   0.12,   0.12, 0.12,
 base_temp                           = 290.
 damp_opt                            = 0,
 zdamp                               = 5000.,  5000.,  5000., 5000.,
 dampcoef                            = 0.2,    0.2,    0.2,   0.2,
 khdif                               = 0,      0,      0,     0,
 kvdif                               = 0,      0,      0,     0,
 non_hydrostatic                     = .true., .true., .true., .true.,
 moist_adv_opt                       = 1,      1,      1,     1,
 use_baseparam_fr_nml                = .t.
 scalar_adv_opt                      = 1,      1,      1,     1,
 /

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., .false.,.false., .false.,
 nested                              = .false., .true., .true., .true.,
 /

 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
EOF


# === link met_em data to wrf/run
rm -rf met_em.d0*.nc
@ n = 0
set len = `expr $periods / 6`
while ( $n <= $len )
     set add = `expr $n \* 6`
     set Curdate = `date +%Y%m%d%H -d "$rundate $utchour hours $add hours"`
     echo $Curdate
     set yyyy = `echo $Curdate | cut -c 1-4`
     set mm   = `echo $Curdate | cut -c 5-6`
     set dd2   = `echo $Curdate | cut -c 7-8`
     set hh   = `echo $Curdate | cut -c 9-10`
     #ls -lht $METDIR/met_em.d0*${yyyy}-${mm}-${dd2}_${hh}:00:00.nc
     ln -s ${METDIR}/met_em.d0*.${yyyy}-${mm}-${dd2}_${hh}:00:00.nc ./
    @ n++ 
end


# rm -rf rsl.error.* rsl.out.* wrfbdy* wrfinput*
# mpiexec -n 60 ./real.exe
# mpiexec -n 72 ./wrf.exe

set SuccessFlag = "llq: There is currently no job status to report"

#=== submit and check real work
echo "llsubmit real.cmd"
set llsub= `llsubmit real.cmd`
set realJobId = `echo $llsub | cut -d\" -f2`
echo "realJobId: $realJobId"
set realStat = " "
@ i = 0
while ( $realStat != $SuccessFlag )
    set realStat = "`llq  $jobid -X cl_cmb`"
    echo "sleep 1 minters"
    sleep 30
    @ i++
end
echo "---------------------------------------"
echo " real work done  successfully!"
echo "---------------------------------------"

#  === submit and check wrf work
echo "llsubmit wrf.cmd"
set llsub= `llsubmit real.cmd`
set wrfJobId = `echo $llsub | cut -d\" -f2`
echo "wrfJobId: $wrfJobId"
set wrfStat = " "
@ i = 0
while ( $wrfStat != $SuccessFlag )
    set wrfStat = "`llq  $jobid -X cl_cmb`"
    echo "sleep 1 minters"
    sleep 30
    @ i++
end

echo "---------------------------------------"
echo " wrf work done  successfully!"
echo "---------------------------------------"

# === copy the wrf result to the specify directory
cp wrfout_d0*_${syyyy}-${smm}-${sdd}_${shh}* $WRFOUTDIR/$rundate$utchour

echo "--------------------------------------------------"
echo " $rundate$runhour wrf work done  successfully!"
echo "--------------------------------------------------"
exit 0





# bsub real.lsf >> realJobId.log
# set realJobId = `cat realJobId.log | tail -1 | cut -c 6-12`
# echo "realJobId: $realJobId"
# set realStat = "EXIT"
# @ i = 0
# while ( $realStat != $SuccessFlag )
#     set realStat = `bjobs | grep $realJobId | cut -d ' ' -f 3`
#     echo "sleep 1 minters"
#     sleep 60
#     @ i++
# end
# echo "---------------------------------------"
# echo " real work done  successfully!"
# echo "---------------------------------------"



