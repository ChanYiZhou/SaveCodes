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

# 导入自定义模块
import maskout
from ECMWF_precip import *

# =========== 定义全局变量 ==========
ECres = 0.125 # unit is deg, 数据空间分辨率
SLON, SLAT = 104.25, 20.5
ELON, ELAT = 112.25, 27.0
NLONS = (ELON - SLON)/ECres + 1
NLATS = (ELAT - SLAT)/ECres + 1
NLONS, NLATS = int(NLONS), int(NLATS)
shpDir = os.path.join(r'/root','PlotECdata','src','shp')  # shapefile的路径
OutFigDir = os.path.join(r'/root','PlotECdata','figs','rain') # 输出图片的路径
Atime = range(24,242,12) # 降水的预报时效
Atime = [str(_).zfill(3) for _ in Atime]
Map = Basemap(projection='cyl', resolution='c', llcrnrlat=SLAT,
            urcrnrlat=ELAT, llcrnrlon=SLON, urcrnrlon=ELON)

# 根据24小时降水等级配置绘图颜色
over_RGB = list(np.array([108,21,49])/255.0)
under_RGB = list(np.array([255,255,255])/255.0)
Bcmap_RGB = [[81,176,48], [82,167,250], [25,84,229], 
	 [220,58,248]]
Bcmap_RGB = np.array(Bcmap_RGB)/255.0
Bcmap_RGB = [list(_) for _ in Bcmap_RGB]
CMAP = matplotlib.colors.ListedColormap(Bcmap_RGB)
#CMAP.set_over((over_RGB[0], over_RGB[1], over_RGB[2]))
CMAP.set_over(tuple(over_RGB))
CMAP.set_under(tuple(under_RGB))
Bounds = [10, 25, 50, 100, 250]
NORM = matplotlib.colors.BoundaryNorm(Bounds, CMAP.N, clip=False)


# 配置汉字字体，根据中文字体文件库及其位置来配置，须自行设定
MYFONTFILE = 'msyh.ttc'
FONTWeight = ['ultralight','extra bold']
FONTWeight = ['bold','ultralight','normal','extra bold']
FONTSize = [5, 8, 8, 12]
MYFONT_SMALL, MYFONT, MYFONT_LEGEND, MYFONT_TITLE = [
    matplotlib.font_manager.FontProperties(fname=MYFONTFILE, size=FONTSize[i], weight=FONTWeight[i])
    for i in range(len(FONTSize))]

# ==============  定义函数  ===============
def plt_Rain(x,y,rain,timestr):
	fig = plt.figure()
	ax = fig.add_axes([0.1, 0.1, 0.70, 0.75],projection=ccrs.PlateCarree())
	Map.readshapefile(os.path.join(shpDir,'guangxi'), name='whatever', drawbounds=True,
	                linewidth=0.5, color='black')
	cs = ax.contourf(x, y, rain, cmap=CMAP, norm=NORM, levels=Bounds, extend='both')
	#cs = ax.contourf(x, y, rain, cmap=CMAP, norm=NORM, levels=Bounds)
	clip=maskout.shp2clip(cs,ax,Map,os.path.join(shpDir,'bou2_4p'),[450000])

	# 设置图题
	init_time, endH = timestr[:10], int(timestr[11:])
	SDH = timestr[6:10]
	AEDH = datetime(int(timestr[:4]),int(timestr[4:6]),int(timestr[6:8]),int(timestr[8:10])) + timedelta(hours=24)
	DatePath = (AEDH - timedelta(hours=endH)).strftime('%Y%m%d%H')
	AEDH = AEDH.strftime('%Y%m%d%H')
	EDH = AEDH[6:10]
	PeriodH = '-'.join([str(endH-24).zfill(3),str(endH).zfill(3)])
	PeriodDH = '-'.join([SDH,EDH])
	axm = plt.gca()
	xlim, ylim = axm.get_xlim(), axm.get_ylim()
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.25, ylim[1]+(ylim[1]-ylim[0])*0.08,
	    u'广 西 EC 模 式 24 小 时 累 计 降 水(mm) 预 报', fontproperties=MYFONT_TITLE)
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.03, ylim[1]+(ylim[1]-ylim[0])*0.02,
	    init_time, fontproperties=MYFONT)
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.45, ylim[1]+(ylim[1]-ylim[0])*0.02,
	    PeriodH, fontproperties=MYFONT)
	plt.text(xlim[1]-(xlim[1]-xlim[0])*0.12, ylim[1]+(ylim[1]-ylim[0])*0.02,
	    PeriodDH, fontproperties=MYFONT)
	
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
                                boundaries=[1] + Bounds + [250],
                                extend='both',
                                extendfrac='auto',
                                ticks=Bounds,
                                spacing='uniform', #'proportional', 'uniform'
                                orientation='vertical')

	# 输出或者保存图形
	flename = AEDH + '_rain.png'
	DatePath = DatePath[:8] + '_' + DatePath[8:]
	OutFigPath = os.path.join(OutFigDir, DatePath)
	if not os.path.exists(OutFigPath): os.makedirs(OutFigPath)
	plt.savefig(os.path.join(OutFigPath,flename), bbox_inches='tight', pad_inches=0.3, dpi=300)
	plt.clf()
	# plt.show()

def main():
	year, month, day, prehour = 2017, 3, 28, '00'
	for hours in Atime:
		print hours
		# 1. read ecmwf data
		if int(prehour) + int(hours) == 24:
			hourLST = ['24']
		else:
			Ehours = hours
			Shours = int(prehour) + int(hours) - 24
			hourLST = [Shours, Ehours]

		Rain_24cumu = []
		for ihours in hourLST:
                        try:
				output = readECMWF_inbox(ihours, year, month, day, prehour)
                        except Exception as e:
				raise e
                                continue 
			rainfall = np.array(output['rainfall']) # 前ihours累计降水
			lats = output['lats'][::-1]
			lons = output['lons']

			latsize = len(list(set(lats)))
			lonsize = len(list(set(lons)))
			SLAT_ID, SLON_ID = lats.index(SLAT)/lonsize, lons.index(SLON)
			ELAT_ID, ELON_ID = lats.index(ELAT)/lonsize, lons.index(ELON)

			XIn0 = np.arange(SLON,ELON+0.5*ECres,ECres)
			YIn0 = np.arange(SLAT,ELAT+0.5*ECres,ECres)
			x, y = np.meshgrid(XIn0, YIn0)
			
			rain_cumu = rainfall.reshape((latsize,lonsize))[::-1,:][SLAT_ID:ELAT_ID+1,SLON_ID:ELON_ID+1]
			Rain_24cumu.append(list(rain_cumu))
		if not Rain_24cumu: continue 
		if len(hourLST) == 2:
			if len(Rain_24cumu) == 2:
				Rain_24cumu = np.array(Rain_24cumu[1]) - np.array(Rain_24cumu[0])
                        else:
				continue
		else:
			Rain_24cumu = np.array(Rain_24cumu[0])

		print 'hours list:', hourLST
		print '24 hours acumulated rain:', Rain_24cumu
		print ''

		# 2.绘制广西降水阴影图
		TimeST = datetime(year, month, day, int(prehour)) + timedelta(hours=int(hours)) - timedelta(hours=24)
		timestr = TimeST.strftime('%Y%m%d%H') + '_' + hours
		plt_Rain(x, y, Rain_24cumu, timestr)
	

# ========== 默认情况下，调用主程序 ==========
if __name__ == '__main__':
    main()
