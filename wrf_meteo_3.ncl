
; Example series of plotting meteograms with WRF ARW model data
; First let's just get and plot t2 at a point
; Add some info to the plot
; Add slp to the plot


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
  slp   = wrf_user_getvar(a,"slp",-1)   ; get slp for all times
  t2_point  = t2(:,18,20)               ; extract a time series at a point
  slp_point  = slp(:,18,20)  

  taus = new(dimsizes(t2_point),"integer") ; create a time reference
  taus = ispan(1,dimsizes(t2_point),1)

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
  wks = gsn_open_wks(type,OutPath+"meteo3")     ; open a workstation

;-----------------------------------------------------------------------

  res = True                            ; Set basic resources both will use
  res@vpXF            = 0.15            ; The left side of the box location
  res@vpWidthF        = 0.70            ; The Width of the plot box
  res@vpHeightF       = 0.20            ; The height of the plot box
  res@tmXBMode       = "Explicit"       ; Define own tick mark labels.
  res@tmXBValues     = taus             ; location of explicit labels
  res@tmXBLabels     = times            ; labels are the locations
  res@tmXTOn         = False            ; turn off the top tick marks
  res@xyLineThicknesses = 2             ; increase line thickness
  res@gsnDraw         = False           ; Don't draw individual plot.
  res@gsnFrame        = False           ; Don't advance frame.
  

  slp_res = res
  slp_res@vpYF            = 0.75        ; The top side of the plot box loc
  slp_res@xyLineColor    =  "red"       ; set line color


  t2_res = res
  t2_res@vpYF            = 0.45         ; The top side of the plot box loc
  t2_res@xyLineColor    =  "blue"       ; set line color

  slp_plot  = gsn_csm_xy(wks,taus,slp_point,slp_res)
  t2_plot  = gsn_csm_xy(wks,taus,t2_point,t2_res)
  draw(slp_plot) 
  draw(t2_plot) 

  frame(wks)                            ; now frame the plot   

;-----------------------------------------------------------------------

end
