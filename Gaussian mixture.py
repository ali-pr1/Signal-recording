# use gaussian mixture for clustering
from sklearn.mixture import GaussianMixture
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
for i in range(4,13):
    trial=pd.DataFrame()
    trial['x'] = np.log(cell_line_df['area'] * cell_line_df['mean_intensity_647'])
    trial['y'] = np.log(cell_line_df['area'] * cell_line_df['mean_intensity_546'])
    gmm = GaussianMixture(n_components=i)
    gmm.fit(trial)
    trial['label']=list(gmm.predict(trial))
    trial['ratio']=cell_line_df['ratio']
    plt.figure(figsize=(16,10))
    plt.title('{:02d}_clusters'.format(i))
    ax=plt.scatter(trial['x'],trial['y'],s=5,c=trial['label'])
    plt.xlabel("log(intensity) of unedited channel")
    plt.ylabel("log(intensity) of edited channel")
    picname = data_dir+'/plots/gaussianMixture_clustering{:02d}.png'.format(i)
    fig = ax.get_figure()
    fig.savefig(picname)
