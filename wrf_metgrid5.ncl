
;   Example script to plot some 3D fields from a single metgrid file
;   November 2008

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
 ; == set necessary path
  InPath   = getenv("InPath")
  OutPath  = getenv("OutPath")
  Infls    = getenv("Infls")

; == read data
  a = addfile(InPath+"met_em.d01.2015-10-03_12_00_00.nc","r")  ; Open a file


; We generate plots, but what kind do we prefer?
;  type = "x11"
 type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,OutPath+"plt_metgrid_5")


  res = True                           ; Set up some basic plot resources
  res@MainTitle = "METGRID FILES"
  res@Footer = False

  pltres = True
  mpres = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        
; Note: we do not have "tc", "ua", "va" in the input field - but we 
;       know how to calculate them

    tc = wrf_user_getvar(a,"tc",0)  ; Calculate tc from TT 
    ua = wrf_user_getvar(a,"ua",0)  ; Get U on mass points
    va = wrf_user_getvar(a,"va",0)  ; Get V on mass points

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    dims = dimsizes(tc)          ; Get dims for tc
    nd = dimsizes(dims)          ; Find out how many dimensions there are
    nl = dims(nd-3)              ; We know 3rd dim from right is nz

    do level = 1,nl-1,5      ; LOOP OVER LEVELS, plot every 5th (surface is 0, lets start one level up)
 
 
     ; Temperature
       opts = res
       opts@cnFillOn = True
       contour = wrf_contour(a,wks,tc(level,:,:),opts)
       delete(opts)
    
     ; Wind 
       opts = res
       vector = wrf_vector(a,wks,ua(level,:,:),va(level,:,:),opts)
       delete(opts)

       plot = wrf_map_overlays(a,wks,(/contour, vector/),pltres,mpres)

    end do      ; END OF LEVEL LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
