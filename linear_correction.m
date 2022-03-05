%% Testing linear transformation of the data for improving clustering
% cosine metric is defined as 1 - (cosine of the angle
% between points). So it is dependent on the origin. For our data, origin
% (and even slope) is somewhat arbitrary. So maybe a correction for total
% least square line can improve our clustering. Here we test this idea on
% "standard curve" cell lines of signal recording experiment e00.

% import data
data=readmatrix('trial.xlsx', 'NumHeaderLines',1);
data=data(:,[2,3]);

k = 12; % number of clusters

% old clustering
[idx,~] = kmeans(data,k,'Distance','Cosine','Replicates',5, ...
        'MaxIter',1000);
figure
gscatter(data(:,1),data(:,2),idx)
title(sprintf('k = %d before transformation', k))
saveas(gcf,'clustering without linear transformation.png')

% clustering after orthogonal linear regression 
[Err, P] = fit_2D_data(data(:,1),data(:,2), 'yes');
X = P(1)*data(:,1);
Y = data(:,2)-P(2);

[idx,~] = kmeans([X,Y],k,'Distance','Cosine','Replicates',5, ...
        'MaxIter',1000);
figure
gscatter(X,Y,idx)
title(sprintf('k = %d after transformation', k))
saveas(gcf,'clustering with linear transformation.png')