# coding:utf8

# attention:
# 使用时调整boundaries参数

# 气温等级色标
StdRGB_AirTemp = [[2, 12, 100], [7, 30, 120], [17, 49, 139], 
				[27, 68, 159], [38, 87, 179], [48, 106, 199],
				[59, 126, 219], [78, 138, 221], [97, 150, 224],
				[116, 163, 226], [135, 175, 229], [155, 188, 232],
				[154, 196, 220], [153, 205, 208], [152, 214, 196],
				[151, 232, 173], [215, 222, 126], [234, 219, 112],
				[244, 217, 99], [250, 204, 79], [247, 180, 45],
				[242, 155, 0], [241, 147, 3], [240, 132, 10],
				[239, 117, 17], [238, 102, 24], [238, 88, 31],
				[231, 75, 26], [224, 63, 22], [217, 51, 18],
				[208, 36, 14], [194, 0, 3], [181, 1, 9],
				[169, 2, 16], [138, 5, 25], [111, 0, 21], [80, 0, 15]    
				]



if __name__ == '__main__':
	import matplotlib.pyplot as plt
	import matplotlib as mpl
	import numpy as np

	fig = plt.figure(figsize=(15, 3))
	ax = fig.add_axes([0.05, 0.475, 0.9, 0.15])

	over_RGB = list(np.array(StdRGB_AirTemp[-1])/255.0)
	under_RGB = list(np.array(StdRGB_AirTemp[0])/255.0)
	Bcmap_RGB = StdRGB_AirTemp[1:len(StdRGB_AirTemp)-1]
	Bcmap_RGB = np.array(Bcmap_RGB)/255.0
	Bcmap_RGB = [list(_) for _ in Bcmap_RGB]
	cmap = mpl.colors.ListedColormap(Bcmap_RGB)
	cmap.set_over(tuple(over_RGB))
	cmap.set_under(tuple(under_RGB))

	bounds = range(-30, 41, 2) # 不同气温等级的代表值
	norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
	cb = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
	                                norm=norm,
	                                boundaries=[-40] + bounds + [40],
	                                extend='both',
	                                extendfrac='auto',
	                                ticks=bounds,
	                                spacing='uniform',
	                                orientation='horizontal')
	cb.set_label('Standard Colorbars of AirTemp, from CMA')

	plt.show()