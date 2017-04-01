# coding:utf8

# attention:
# 使用时调整boundaries参数

# 干旱等级色标
StdRGB_drought = [
[254, 217, 99], # 轻旱
[236, 152, 0], # 中旱    
[221, 83, 30], # 重旱
[177, 9, 9] #  特旱   
]



if __name__ == '__main__':
	import matplotlib.pyplot as plt
	import matplotlib as mpl
	import numpy as np

	fig = plt.figure(figsize=(8, 3))
	ax = fig.add_axes([0.05, 0.475, 0.9, 0.15])

	over_RGB = list(np.array(StdRGB_drought[-1])/255.0)
	under_RGB = list(np.array(StdRGB_drought[0])/255.0)
	Bcmap_RGB = StdRGB_drought[1:len(StdRGB_drought)-1]
	Bcmap_RGB = np.array(Bcmap_RGB)/255.0
	Bcmap_RGB = [list(_) for _ in Bcmap_RGB]
	cmap = mpl.colors.ListedColormap(Bcmap_RGB)
	cmap.set_over(tuple(over_RGB))
	cmap.set_under(tuple(under_RGB))

	bounds = [1, 2, 3, 4] # 不同干旱等级的代表值
	norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
	cb = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
	                                norm=norm,
	                                boundaries=[-10] + bounds + [10],
	                                extend='both',
	                                extendfrac='auto',
	                                ticks=bounds,
	                                spacing='uniform',
	                                orientation='horizontal')
	cb.set_label('Standard Colorbars of Drought, from CMA')

	plt.show()