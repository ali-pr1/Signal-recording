#Using Optics for clustering
from sklearn.cluster import OPTICS
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
for i in range(5,100,5):
    trial=pd.DataFrame()
    trial['x'] = np.log(cell_line_df['area'] * cell_line_df['mean_intensity_647'])
    trial['y'] = np.log(cell_line_df['area'] * cell_line_df['mean_intensity_546'])
    Optics_clustering = OPTICS(min_samples=i,metric='braycurtis').fit(trial)
    score = metrics.silhouette_score(trial,Optics_clustering.labels_, metric='braycurtisn')
    trial['label']=list(Optics_clustering.labels_)
    trial['ratio']=cell_line_df['ratio']
    plt.figure(figsize=(16,10))
    plt.title('minsamp{:02d}_clusters'.format(i)+'/silhouette Score: %.3f' % score)
    ax=plt.scatter(trial['x'],trial['y'],s=5,c=trial['label'])
    plt.xlabel("log(intensity) of unedited channel")
    plt.ylabel("log(intensity) of edited channel")
    picname = data_dir+'/plots/optics/braycurtis Optics_clustering_samp{:02d}.png'.format(i)
    fig = ax.get_figure()
    fig.savefig(picname)
