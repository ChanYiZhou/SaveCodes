# coding:utf8

from config import *

# fn = 'W_NAFP_C_ECMF_20160117175539_P_C1D01171200011712011.bz2'

# 全局变量，EC数据的经纬度范围
Nlon,Xlon,Nlat,Xlat = 60, 150, -10, 60 # 位势高度EC数据的经纬度范围(deg)
grid_delta = 0.25 # 位势高度EC数据的空间网格间隔(deg)
NumLON = int((Xlon - Nlon)/grid_delta) + 1
NumLAT = int((Xlat - Nlat)/grid_delta) + 1

def wait_for_readable(f, max_wait_time=120):
    def isReadable(f):
        return int(oct(os.stat(f).st_mode)[-1]) >= 4
    if not isReadable(f):
        w = 0
        while w < max_wait_time:
            if isReadable(f):
                break
            else:
                import time
                time.sleep(1)
                w += 1


def readECMWF_inbox(hours,year,month,day,prehour,levnum):
    '''
        INPUTS:
            hours = "3","6","9","12","18","24","36","72",...
            year,month,day
            prehour = "00" or "12"
            levnum = 0, 1, 2, ....

        OUTPUTS:
            output in a dict
    '''
    thetime = datetime(year,month,day,int(prehour))
    thetime_pre = thetime + timedelta(hours=int(hours))
    fn = 'W_NAFP_C_ECMF_*_P_C1D{}00{}001'.format(
        thetime.strftime('%m%d%H'),
        thetime_pre.strftime('%m%d%H'),
    )
    fn_fullpath = glob.glob(os.path.join(ECMWF_FULLPATH, fn))
    fn_fullpath = fn_fullpath[0] if fn_fullpath else ''
    if fn_fullpath:
        wait_for_readable(fn_fullpath)
    else:
        f_bz2 = glob.glob(os.path.join(ECMWF_FULLPATH, fn + '.bz2'))
        f_bz2 = f_bz2[0] if f_bz2 else ''
        if f_bz2:
            os.system('bunzip2 -k {}'.format(f_bz2))
            fn_fullpath = f_bz2[:-4]
    grbs = pygrib.open(fn_fullpath)
    # =============== test variables ==================== #
    # grb_rh = grbs.select(nameECMF='Relative humidity')
    # print grb_rh
    # exit()
    # =================================================== #
    # uwind
    grb_U = grbs.select(nameECMF='U component of wind')[levnum]
    u = grb_U.values
    # lats.ravel(), lons.ravel(), points_in_box is the index of points in lats.ravel() or lons.ravel()
    lats,lons = grb_U.latlons()
    lats,lons = [i.ravel() for i in [lats,lons]]
    points_in_box = [i for i in range(len(lats)) if Nlat<=lats[i]<=Xlat and Nlon<=lons[i]<=Xlon] # Nlon,Xlon,Nlat,Xlat
    # vwnd
    grb_V = grbs.select(nameECMF='V component of wind')[levnum] 
    v = grb_V.values
    # Geopotential Height
    grb_H = grbs.select(nameECMF='Geopotential Height')[levnum] 
    h = grb_H.values
    # Relative humidity
    grb_rh = grbs.select(nameECMF='Relative humidity')[levnum]
    rh = grb_rh.values
    # take data for points in the box, maintain 1 decimal
    u,v,h,rh = [i.ravel() for i in [u,v,h,rh]]
    lats,lons = [
        [round(i[points_in_box[j]],3) for j in range(len(points_in_box))] for i in [lats,lons]
    ]
    u,v,h,rh = [
        [round(i[points_in_box[j]],1) for j in range(len(points_in_box))] for i in [u,v,h,rh]
    ]
    output = {
        'thetime':thetime, # forecast time UTC
        'thetime_pre':thetime_pre, # forecasted time UTC
        'lats':lats, # list of lats in box, same as below
        'lons':lons,
        'uwind':u,
        'vwind':v,
        'geoheight':h,
        'RH':rh,
    }
    return output


if __name__ == '__main__':
    # hours, year, month, day, prehour = '24', 2016, 8, 31, '12'
    hours, year, month, day, prehour = '24', 2017, 3, 6, '00'
    output = readECMWF_inbox(hours, year, month, day, prehour)
    print output
    exit()
    # write 'lats_lons.pkl' and 'points.txt'
    lons, lats = [output.get(i) for i in ['lons', 'lats']]
    lats_lons = {'lats':lats, 'lons':lons}
    pkl = open('lats_lons.pkl', 'wb')
    pickle.dump(lats_lons, pkl)
    pkl.close()
    points = np.vstack([lons, lats]).T
    np.savetxt('points.txt', points, fmt='%1.3f')
    '''
    import pickle
    lats_lons = pickle.load(open('lats_lons.pkl', 'rb'))
    lats, lons = [lats_lons.get(i) for i in ('lats', 'lons')]

    grid_x,grid_y = np.mgrid[Nlon:Xlon+grid_delta:grid_delta,Nlat:Xlat+grid_delta:grid_delta] # grid_delta
    points2 = np.vstack([grid_x.T.ravel(),grid_y.T.ravel()[::-1]]).T

    points2 == points
    '''