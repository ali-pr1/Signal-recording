from scipy.spatial import ConvexHull
lst=['black','red','teal','peru','orange','navy','purple','cyan','steelblue','sienna','brown','forestgreen','red']
% choose for i= kmeans you want
i=2
file_name = data_dir+'/cosine kmeans_{:d}_final .xlsx'.format(i)
df1=pd.read_excel(file_name)
dfa=pd.DataFrame()
x=df1["disX"]
y=df1["disY"]
t=df1["freq"]
plt.title('{:02d}_clusters'.format(i))
for c in range(1,i+1):
    x1=np.array(df1[df1['label']==c]['disX'])
    y1=np.array(df1[df1['label']==c]['disY'])
    xy = np.hstack((x1[:,np.newaxis],y1[:,np.newaxis]))
    hull = ConvexHull(xy)
    plt.plot(x1[hull.vertices], y1[hull.vertices],c=lst[c-1])
plt.scatter(x,y,s=5,c=t)
plt.xlabel("log(intensity) of unedited channel")
plt.ylabel("log(intensity) of edited channel")
plt.colorbar(label='fraction of edited barcodes')
picname = data_dir+'/plots/freq_{:2d}.png'.format(i)
plt.savefig(picname)
