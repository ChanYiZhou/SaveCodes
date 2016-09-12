
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Create a single skewT plot

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

; == set necessary path
  InPath   = getenv("InPath")
  OutPath  = getenv("OutPath")
  Infls    = getenv("Infls")
  
 ; == read input data
  a = addfile(InPath+Infls,"r") 

; We generate plots, but what kind do we prefer?
; type = "x11"
 type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,OutPath+"plt_SkewT")

  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need at time 2        

    tc  = wrf_user_getvar(a,"tc",1)         ; T in C
    td  = wrf_user_getvar(a,"td",1)         ; dew point temperature
    p   = wrf_user_getvar(a, "pressure",1)  ; grid point pressure
    z   = wrf_user_getvar(a, "z",1)         ; grid point height
    uvm = wrf_user_getvar(a,"uvmet",1)      ; umet and vmet averaged to mass points
	; This is a 4D array where
	; uvm(0,:,:,:) is umet, and
    ; uvm(1,:,:,:) is vmet, and
	; This function rotate winds to earth coord.

    ; extract u and v from uvm array, and turn wind into kts
      u   = uvm(0,:,:,:)*1.94386 
      v   = uvm(1,:,:,:)*1.94386

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get ij point in model domain for our location of interest
; loc(1) is south-north (y) and loc(0) is west-east (x)
; Ensure this point is in the domain, as we are not checking
; We are interested in NCL array pointers, so subtract 1 

  loc = wrf_user_ll_to_ij(a, 102., 37., True)
  locX = loc(0) - 1
  locY = loc(1) - 1


; Define a few skew-T plotting options
  skewtOpts          = True
  skewtOpts@DrawHeightScale   = True    ; plot height scale on side
  skewtOpts@DrawHeightScaleFt = False   ; plot height scale in km
  skewtOpts@DrawStandardAtm   = True    ; draw standard atm on plot
  skewtOpts@vpXF              = 0.12    ; controls off-set from left
  skewtOpts@vpYF              = 0.87    ; controls off-set from top
  skewtOpts@vpWidthF          = 0.75    ; controls size of plot
  skewtOpts@vpHeightF         = 0.75    ; controls size of plot
  skewtOpts@DrawFahrenheit    = False   ; use deg C scale
  skewtOpts@tiMainFontHeightF = 0.015   ; change height of main title
 ;skewtOpts@DrawColLine       = False   ; draw lines in black
  skewtOpts@DrawColAreaFill   = True    ; color on background plot
 ;skewtOpts@DrawColAreaColor  = "Green" ; final color may depend on the color table used
  skewtOpts@DrawColAreaColor  = 53      ; Light Green for WhViBlGrYeOrReWh color table
  skewtOpts@PrintOpts         = False   ; do not print options out


; Get the skew-T background
  skewtOpts@tiMainString = "Sounding at 102E & 37N"
  skewt_bkgd             = skewT_BackGround (wks, skewtOpts)
  draw (skewt_bkgd)


; Draw the skew-T plot
  dataOpts           = True
  dataOpts@Parcel    = 1
  dataOpts@WspdWdir  = False  ; wind speed and dir [else: u,v]
  dataOpts@HspdHdir  = True   ; wind speed and dir [else: u,v]
  dataOpts@PlotWindH = False  ; plot wind barbs at h lvls [pibal; special]
  skewT_data = skewT_PlotData(wks, skewt_bkgd, p(:,locY,locX), \
                                              tc(:,locY,locX), \
                                              td(:,locY,locX), \
                                               z(:,locY,locX), \
                                               u(:,locY,locX), \
                                               v(:,locY,locX), \
                                              dataOpts)

; Close the frame
  frame(wks)

end
