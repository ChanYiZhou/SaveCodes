
; Example series of plotting meteograms with WRF ARW model data
; First let's just get and plot t2 at a point
; Add some into to the plot


;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;***********************************************
begin
;***********************************************
; == set necessary path
  InPath   = getenv("InPath")
  OutPath  = getenv("OutPath")
  Infls    = getenv("Infls")
  
 ; == read input data
  a = addfile(InPath+Infls,"r") 

  t2    = wrf_user_getvar(a,"T2",-1)    ; get t2 for all times
  t2_point  = t2(:,18,20)               ; extract a time series at a point
  
  taus = new(dimsizes(t2_point),"integer") ; create a time reference
  taus = ispan(1,dimsizes(t2_point),1)
  ;taus = (/ 1., 2., 3./)       ; create a time reference

; get time information and strip out the day and hour
  times_in_file = a->Times
  dims = dimsizes(times_in_file)
  times = new(dims(0),string)
  do i=0,dims(0)-1
    times(i) = chartostring(times_in_file(i,8:12))
  end do

; We generate plots, but what kind do we prefer?
 ; type = "x11"
 type = "pdf"
 ; type = "ps"
 ; type = "ncgm"
  wks = gsn_open_wks(type,OutPath+"meteo2")     ; open a workstation

  t2_res = True
  t2_res@tmXBMode       = "Explicit"    ; Define own tick mark labels.
  t2_res@tmXBValues     = taus          ; location of explicit labels
  t2_res@tmXBLabels     = times         ; labels are the locations
  t2_res@tmXTOn         = False         ; turn off the top tick marks
  t2_res@xyLineThicknesses = 2          ; increase line thickness
  t2_res@xyLineColor    =  "blue"       ; set line color

  t2_plot  = gsn_csm_xy(wks,taus,t2_point,t2_res)

end
