# coding:utf8

# attention:
# 使用时调整boundaries参数

# 相对湿度的色标分级
StdRGB_RH = [
[151, 232, 173], #  0~10%
[153, 210, 202], # 10~20%
[155, 188, 232], # 20~30%
[107, 157, 225], # 30~40%
[59, 126, 219], # 40~50%
[43, 92, 194], # 50~60%
[28, 59, 169], # 60~70%
[17, 44, 144], # 70~80%
[7, 30, 120], # 80~90%
[0, 15, 80] # 90~100% 
]


if __name__ == '__main__':
	import matplotlib.pyplot as plt
	import matplotlib as mpl
	import numpy as np

	fig = plt.figure(figsize=(8, 3))
	ax = fig.add_axes([0.05, 0.475, 0.9, 0.15])

	over_RGB = list(np.array(StdRGB_RH[-1])/255.0)
	under_RGB = list(np.array(StdRGB_RH[0])/255.0)
	Bcmap_RGB = StdRGB_RH[1:len(StdRGB_RH)-1]
	Bcmap_RGB = np.array(Bcmap_RGB)/255.0
	Bcmap_RGB = [list(_) for _ in Bcmap_RGB]
	cmap = mpl.colors.ListedColormap(Bcmap_RGB)
	cmap.set_over(tuple(over_RGB))
	cmap.set_under(tuple(under_RGB))

	bounds = range(10,100,10)
	norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
	cb = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
	                                norm=norm,
	                                boundaries=[1] + bounds + [100],
	                                extend='both',
	                                # Make the length of each extension
	                                # the same as the length of the
	                                # interior colors:
	                                extendfrac='auto',
	                                ticks=bounds,
	                                spacing='uniform',
	                                orientation='horizontal')
	cb.set_label('Standard Colorbars of Relative Humidity, from CMA')

	plt.show()