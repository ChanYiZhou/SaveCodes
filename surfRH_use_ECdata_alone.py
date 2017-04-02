#!/usr/bin/env python
# -*- coding: utf-8 -*-
# -*- version: python2.7 -*-


# =========== 导入模块 ==========
import os
import time
import shapefile
import matplotlib 
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np 
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from cartopy.mpl.ticker import LongitudeFormatter,LatitudeFormatter
from mpl_toolkits.basemap import Basemap
from datetime import datetime, timedelta

# === 导入自定义模块
import maskout
from ECMWF_PRES import *
from GX_CityLod import NAME, LON, LAT
from StdRGB_RH import StdRGB_RH

# =========== 定义全局变量 ==========
LevNum = 15 # (15, 950hPa), (8, 1000hPa), (6, 925hPa), (16, 700hPa), (17, 850hPa)
ECres = 0.25 # unit is deg, 数据空间分辨率
SLON, ELON = 104.25, 112.25
SLAT, ELAT = 20.5, 27.0
NLONS = (ELON - SLON)/ECres + 1
NLATS = (ELAT - SLAT)/ECres + 1
NLONS, NLATS = int(NLONS), int(NLATS)
shpDir = os.path.join(r'/Users/chan/Desktop','ECdata_Plot','src','shp')  # shapefile的路径
OutFigDir = os.path.join(r'/Users/chan/Desktop','ECdata_Plot','figs','SFC') # 输出图片的路径
Atime = range(0,242,12) # 相对湿度的预报时效,待定
Atime = [str(_).zfill(3) for _ in Atime]
Map = Basemap(projection='cyl', resolution='c', llcrnrlat=SLAT,
            urcrnrlat=ELAT, llcrnrlon=SLON, urcrnrlon=ELON)

# ==== 配置汉字字体，根据中文字体文件库及其位置来配置，须自行设定
MYFONTFILE = 'msyh.ttc'
FONTWeight = ['ultralight','extra bold']
FONTWeight = ['bold','ultralight','normal','extra bold']
FONTSize = [5, 8, 8, 12]
MYFONT_SMALL, MYFONT, MYFONT_LEGEND, MYFONT_TITLE = [
    matplotlib.font_manager.FontProperties(fname=MYFONTFILE, size=FONTSize[i], weight=FONTWeight[i])
    for i in range(len(FONTSize))]

# ==============  定义函数  ===============
def plt_level(rh):
	"""
	根据相对湿度数据的极值，创建适合的标准色标等
	注意，此处相对湿度为10
	"""
	Nt, Xt = np.min(rh), np.max(rh)
	XRound = int(np.ceil(Xt/10) * 10) # 向上取整，近似最大值
	NRound = int(np.floor(Nt/10) * 10) # 向下取整，近似最小值
	GRH = range(0, 101, 10) # 设置通用相对湿度范围
	Nid, Xid = GRH.index(NRound), GRH.index(XRound)
	RHRGB = StdRGB_RH[Nid-1:Xid+2]
	over_RGB = list(np.array(RHRGB[-1])/255.0)
	under_RGB = list(np.array(RHRGB[0])/255.0)
	Bcmap_RGB = RHRGB[1:len(RHRGB)-1]
	Bcmap_RGB = np.array(Bcmap_RGB)/255.0
	Bcmap_RGB = [list(_) for _ in Bcmap_RGB]
	cmap = matplotlib.colors.ListedColormap(Bcmap_RGB)
	cmap.set_over(tuple(over_RGB))
	cmap.set_under(tuple(under_RGB))
	bounds = range(NRound, XRound+1, 10) # 不同相对湿度等级的代表值
	norm = matplotlib.colors.BoundaryNorm(bounds, cmap.N)

	return cmap, bounds, norm


def plt_fig(x,y,rh,timestr):
	fig = plt.figure()
	ax = fig.add_axes([0.1, 0.1, 0.70, 0.75],projection=ccrs.PlateCarree())
	# ax = plt.subplot(1,1,1,projection=ccrs.PlateCarree())

	Map.readshapefile(os.path.join(shpDir,'guangxi'), name='whatever', drawbounds=True,
	                linewidth=0.2, color='gray')

	CMAP, Bounds, NORM = plt_level(rh)
	cs = ax.contourf(x, y, rh, cmap=CMAP, norm=NORM, levels=Bounds)
	# cs = ax.contourf(x, y, rh)
	CS = ax.contour(x, y, rh, colors='w', linewidth=1.5)
	plt.clabel(CS, fontsize=7, inline=1, fmt='%.1f')
	clip=maskout.shp2clip(cs,ax,Map,os.path.join(shpDir,'bou2_4p'),[450000])
	clip1=maskout.shp2clip(CS,ax,Map,os.path.join(shpDir,'bou2_4p'),[450000])

	# 开启地图上的城市标记
	for i in range(len(NAME)):
		plt.text(
				LON[i], LAT[i], NAME[i],
				fontproperties=MYFONT,
				horizontalalignment='center',
				verticalalignment='top',
				)

	# 设置图题
	fcstdates = timestr[:8]+'_'+timestr[8:10]
	hours = timestr[-3:]
	if int(hours) < 100: hours = hours[1:]
	axm = plt.gca()
	xlim, ylim = axm.get_xlim(), axm.get_ylim()
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.1, ylim[1]+(ylim[1]-ylim[0])*0.08,
	    u'广 西 全 区 未 来 '+hours+u' 小 时 950hPa 等 压 面 相 对 湿 度 预 报', fontproperties=MYFONT_TITLE)
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.03, ylim[1]+(ylim[1]-ylim[0])*0.02,
	    u'起 报 时 间 ：'+fcstdates, fontproperties=MYFONT)
	plt.text(xlim[1]-(xlim[1]-xlim[0])*0.16, ylim[1]+(ylim[1]-ylim[0])*0.02,
	    u'相 对 湿 度 ：%', fontproperties=MYFONT)
	
	# 标注坐标轴
	ax.set_xticks([106, 108, 110, 112], crs=ccrs.PlateCarree())
	ax.set_yticks([21, 23, 25, 27], crs=ccrs.PlateCarree())
	# zero_direction_label用来设置经度的0度加不加E和W
	lon_formatter = LongitudeFormatter(zero_direction_label=False)
	lat_formatter = LatitudeFormatter()
	ax.xaxis.set_major_formatter(lon_formatter)
	ax.yaxis.set_major_formatter(lat_formatter)

	# 添加图例
	fig.subplots_adjust(top=0.66, bottom=0.26, left=0.83, right=0.85)
	axcb = fig.add_subplot(1, 1, 1)
	cb = matplotlib.colorbar.ColorbarBase(axcb, cmap=CMAP,
                                norm=NORM,
                                boundaries=[1] + Bounds + [100],
                                extend='both',
                                extendfrac='auto',
                                ticks=Bounds,
                                spacing='uniform', #'proportional', 'uniform'
                                orientation='vertical')

	# 输出或者保存图形
	flename = timestr + '_RH950.png'
	OutFigPath = os.path.join(OutFigDir, fcstdates)
	if not os.path.exists(OutFigPath): os.makedirs(OutFigPath)
	plt.savefig(os.path.join(OutFigPath,flename), bbox_inches='tight', pad_inches=0.3, dpi=300)
	plt.clf()
	# plt.show()

def main():
	for idelta in range(1):
		dates = datetime(2017, 3, 6) + timedelta(days=idelta)
		datestr = dates.strftime('%Y%m%d')
		year = int(datestr[:4])
		month, day = int(datestr[4:6]), int(datestr[6:])
		for prehour in ['00']: # '00', '12'
			for hours in Atime[2:3]:
				try:
					output = readECMWF_inbox(hours, year, month, day, prehour, LevNum)
				except Exception as e:
					raise e
					continue
				RHIn =  np.array(output['RH'])
				lons = output['lons']
				lats = output['lats'][::-1]
				# print sorted(list(set(lats)))
				# print sorted(list(set(lons)))

				latsize, lonsize = len(list(set(lats))), len(list(set(lons)))
				SLAT_ID, SLON_ID = lats.index(SLAT)/lonsize, lons.index(SLON)
				ELAT_ID, ELON_ID = lats.index(ELAT)/lonsize, lons.index(ELON)

				XIn0 = np.arange(SLON,ELON+0.5*ECres,ECres)
				YIn0 = np.arange(SLAT,ELAT+0.5*ECres,ECres)
				x, y = np.meshgrid(XIn0, YIn0)

				rh = RHIn.reshape((latsize,lonsize))[::-1,:][SLAT_ID:ELAT_ID+1,SLON_ID:ELON_ID+1]
				# print np.max(rh),np.min(rh)

				# 3. plot rh at 950hpa level
				fcstdates = datetime(year,month,day,int(prehour)).strftime('%Y%m%d%H')
				timestr = fcstdates+'_'+ hours
				plt_fig(x,y,rh,timestr)
				
	
# ========== 默认情况下，调用主程序 ==========
if __name__ == '__main__':
    main()
