# coding:utf8

# attention:
# 使用时调整boundaries参数

# 风力等级色标
StdRGB_WindLev = [
[151, 232, 173], 
[153, 210, 202],     
[155, 188, 232], 
[107, 157, 225],
[59, 126, 219],
[43, 92, 194],
[28, 59, 169],
[17, 44, 144],
[7, 30, 120],
[70, 25, 129],
[134, 21, 138],
[200, 17, 169]   
]



if __name__ == '__main__':
	import matplotlib.pyplot as plt
	import matplotlib as mpl
	import numpy as np

	fig = plt.figure(figsize=(8, 3))
	ax = fig.add_axes([0.05, 0.475, 0.9, 0.15])

	over_RGB = list(np.array(StdRGB_WindLev[-1])/255.0)
	under_RGB = list(np.array(StdRGB_WindLev[0])/255.0)
	Bcmap_RGB = StdRGB_WindLev[1:len(StdRGB_WindLev)-1]
	Bcmap_RGB = np.array(Bcmap_RGB)/255.0
	Bcmap_RGB = [list(_) for _ in Bcmap_RGB]
	cmap = mpl.colors.ListedColormap(Bcmap_RGB)
	cmap.set_over(tuple(over_RGB))
	cmap.set_under(tuple(under_RGB))

	bounds = range(6,18) # 不同风力等级的代表值
	norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
	cb = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
	                                norm=norm,
	                                boundaries=[1] + bounds + [18],
	                                extend='both',
	                                extendfrac='auto',
	                                ticks=bounds,
	                                spacing='uniform',
	                                orientation='horizontal')
	cb.set_label('Standard Colorbars of WindLev, from CMA')

	plt.show()