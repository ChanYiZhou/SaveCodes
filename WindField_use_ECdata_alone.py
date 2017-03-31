#!/usr/bin/env python
# -*- coding: utf-8 -*-
# -*- version: python2.7 -*-
# ==================== refer URL =========================== #
# http://matplotlib.org/examples/pylab_examples/barb_demo.html
# ==================== refer URL =========================== # 

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
from datetime import datetime


# 导入自定义模块
from ECMWF import *

# 设置全局变量
shpDir = '/root/PlotECdata/src/shp/'  # shapefile的路径
OutFigPath = '/root/PlotECdata/figs/wind/' # 输出图片的路径
Atime = range(0,242,12) # 风场的预报时效
Atime = [str(_).zfill(3) for _ in Atime]
Map = Basemap(projection='cyl', resolution='c', llcrnrlat=20.5,
            urcrnrlat=27.0, llcrnrlon=104.3, urcrnrlon=112.2)

# 风速等级分类
grade_label = ['0', '1', '2', '3-4', '5-6', '7-8', '9-10', '11-12', 
    '13-14', '15-16', '17-18', '>=19', '21-22', '23-24', 
    '25-26', '27-28']

# 配置汉字字体，根据中文字体文件位置来配置，须自行设定
MYFONTFILE = 'msyh.ttc'
FONTWeight = ['ultralight','extra bold']
FONTSize = [9, 12]
MYFONT,MYFONT_TITLE = [
    matplotlib.font_manager.FontProperties(fname=MYFONTFILE, size=FONTSize[i], weight=FONTWeight[i])
    for i in range(len(FONTSize))]

def plt_WndBarb(XIn, YIn, U, V, timestr):
	fig = plt.figure()
	ax = fig.add_axes([0.1, 0.1, 0.70, 0.75],projection=ccrs.PlateCarree())
	# ax = plt.subplot(1,1,1,projection=ccrs.PlateCarree())

	Map.readshapefile(shpDir+'bou2_4p', name='whatever', drawbounds=True,
	                linewidth=0.5, color='black')

	ax.barbs(XIn, YIn, U, V, np.sqrt(U*U + V*V), length=4, pivot='tip',fill_empty=True, 
	  rounding=True, sizes=dict(emptybarb=0.001, spacing=0.3, height=0.5))

	# 标注经纬度坐标轴
	ax.set_xticks([106, 108, 110, 112], crs=ccrs.PlateCarree())
	ax.set_yticks([21, 23, 25, 27], crs=ccrs.PlateCarree())
	# zero_direction_label用来设置经度的0度加不加E和W
	lon_formatter = LongitudeFormatter(zero_direction_label=False)
	lat_formatter = LatitudeFormatter()
	ax.xaxis.set_major_formatter(lon_formatter)
	ax.yaxis.set_major_formatter(lat_formatter)

	axm = plt.gca()
	xlim, ylim = axm.get_xlim(), axm.get_ylim()
	fcstdates = timestr[:8]+'_'+timestr[8:10]
	hours = timestr[11:]
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.25, ylim[1]+(ylim[1]-ylim[0])*0.08,
	    u'广 西 全 区 未 来 '+hours+u' 小 时 10m 风 场 预 报', fontproperties=MYFONT_TITLE)
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.02, ylim[1]+(ylim[1]-ylim[0])*0.02,
	    u'起 报 时 间 ：'+fcstdates, fontproperties=MYFONT)

    # 添加风向标图例
	naxes = len(grade_label)
	fig.subplots_adjust(top=0.75, bottom=0.15, left=0.78, right=0.95)
	for iplt in range(naxes):
	  axn = fig.add_subplot(naxes, 1, iplt+1)
	  axn.set_xlim(0.0,1.0)
	  axn.set_ylim(0.0,1.0)
	  if iplt == 0:
	    axn.barbs(0.5,0.5,0.0,0.0, flagcolor='r',
	       barbcolor=['b', 'b'], barb_increments=dict(half=1, full=2, flag=10)) # 绘制0级风，散点图
	    tm = plt.gca()
	    xlim, ylim = tm.get_xlim(), tm.get_ylim()
	    plt.text((xlim[1]-xlim[0])*0.20, ylim[1]+(ylim[1]-ylim[0])*0.15,u'风 速 : 米每秒',fontproperties=MYFONT)
	  elif iplt == 1:
	    line, = axn.plot([0.26,0.5], [0.5,0.5], '-', color='b')          # 绘制1级风，直线图
	  else:
	    x = (iplt-1)* 1.0
	    axn.barbs(0.5,0.5,x,0.0, flagcolor='r',
	       barbcolor=['b', 'b'], barb_increments=dict(half=1, full=2, flag=10))

	  axn.text(0.60,0.36,grade_label[iplt])
	  axn.xaxis.set_visible(False)
	  axn.yaxis.set_visible(False)
	  axn.set_frame_on(False)

    # plt.show()
	flename = timestr + '_' + 'Windbarb.png'
	plt.savefig(OutFigPath+flename, bbox_inches='tight', pad_inches=0.3, dpi=300)
        plt.close(fig)
	plt.clf()


def plt_WndVector(X,Y,U,V,timestr):
	fig = plt.figure()
	ax = plt.subplot(1,1,1,projection=ccrs.PlateCarree())

	Map.readshapefile(shpDir+'bou2_4p', name='whatever', drawbounds=True,
	                linewidth=0.5, color='black')
	M = np.hypot(U,V)
	#ax.quiver(X, Y, U, V, M, transform=vector_crs, regrid_shape=30)
	Q = ax.quiver(X, Y, U, V, M, units='x', pivot='tip', width=0.012,
	    scale=4 / 0.15)
	qk = ax.quiverkey(Q, 0.86, 0.92, 2.5, r'$10 \frac{m}{s}$', labelpos='E',
	    coordinates='figure')

	# 标注坐标轴
	ax.set_xticks([106, 108, 110, 112], crs=ccrs.PlateCarree())
	ax.set_yticks([21, 23, 25, 27], crs=ccrs.PlateCarree())
	# zero_direction_label用来设置经度的0度加不加E和W
	lon_formatter = LongitudeFormatter(zero_direction_label=False)
	lat_formatter = LatitudeFormatter()
	ax.xaxis.set_major_formatter(lon_formatter)
	ax.yaxis.set_major_formatter(lat_formatter)

	axm = plt.gca()
	xlim, ylim = axm.get_xlim(), axm.get_ylim()
	fcstdates = timestr[:8]+'_'+timestr[8:10]
	hours = timestr[11:]
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.25, ylim[1]+(ylim[1]-ylim[0])*0.08,
	    u'广 西 全 区 未 来 '+hours+u' 小 时 10m 风 场 预 报 图', fontproperties=MYFONT_TITLE)
	plt.text(xlim[0]+(xlim[1]-xlim[0])*0.02, ylim[1]+(ylim[1]-ylim[0])*0.02,
	    u'起 报 时 间 ：'+fcstdates, fontproperties=MYFONT)

	# plt.show()
	flename = timestr + '_' + 'WindVector.png'
	plt.savefig(OutFigPath+flename, bbox_inches='tight', pad_inches=0.3, dpi=300)
        plt.close(fig)
	plt.clf()


def main():
	# 1. set time
	#CurrTime = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        CurrTime = '2017-03-09 12:00:00'
	year, month = int(CurrTime[:4]), int(CurrTime[5:7])
	day, hour = int(CurrTime[8:10]), CurrTime[11:13]
    
	for hours in Atime:
	    # 2. read ecmwf data
		# hours, year, month, day, prehour = '24', 2017, 3, 6, '00'
		prehour = hour
		output = readECMWF_inbox(hours, year, month, day, prehour)
		UIn = output['uwind']
		VIn = output['vwind']
		XIn = output['lons']
		YIn = output['lats']
		U, V = np.array(UIn), np.array(VIn)

		# 3. plot uv wind at 10m level
		fcstdates = datetime(year,month,day,int(prehour)).strftime('%Y%m%d%H')
		timestr = fcstdates+'_'+ hours.zfill(3)
		plt_WndBarb(XIn,YIn,U,V,timestr)
		plt_WndVector(XIn,YIn,UIn,VIn,timestr)

if __name__ == '__main__':
    main()
