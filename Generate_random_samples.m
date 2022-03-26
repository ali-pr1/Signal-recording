% generate random samples; consider you want replacment or not
cd 'E:/ALI/processing project/signal recording'
samp_size=[2000:2000:25000];
data=readmatrix('trial.xlsx', 'NumHeaderLines',1);
data=data(:,[2,3]);
[Err, P] = fit_2D_data(data(:,1),data(:,2), 'yes');
%X = P(1)*data(:,1);
%Y = data(:,2)-P(2);
%data=zeros(size(data));
%data(:,1)=X;
%data(:,2)=Y;
Calinski=zeros(1,length(samp_size));
silhouette=zeros(1,length(samp_size));
Davies=zeros(1,length(samp_size));
for i=1:length(samp_size)
    ran=randsample(21157,samp_size(i),true);
    new_data=zeros(samp_size(i),2);
    for j=1:samp_size(i)
        new_data(j,:)=data(ran(j),:);
    end
    clust = zeros(size(new_data,1),5);
    % I'm a little unsure about choosing c
    for c = 6:10
        [idx,C] = kmeans(new_data,c,'Distance','Cosine','Replicates',5, ...
            'MaxIter',1000);
        %figure
        %gscatter(new_data(:,1),new_data(:,2),idx)
        label=idx;
        clust(:,c-5)=label;
    end
    eva1 = evalclusters(new_data,clust,'CalinskiHarabasz');
    eva2=  evalclusters(new_data,clust,'silhouette','Distance','cosine');
    eva3=  evalclusters(new_data,clust,'DaviesBouldin');
    Calinski(i)=eva1.OptimalK;
    silhouette(i)=eva2.OptimalK;
    Davies(i)=eva3.OptimalK;
end
inf=zeros(4,5);
inf(1,:)=[6:10];
for c=6:10
    inf(2,c-5)=sum(Calinski==c)/length(Calinski);
    inf(3,c-5)=sum(silhouette==c)/length(silhouette);
    inf(4,c-5)=sum(Davies==c)/length(Davies);
end
figure
plot(inf(1,:),inf(2,:))
title('Calinski');
figure
plot(inf(1,:),inf(3,:))
title('silhouette');
figure
plot(inf(1,:),inf(4,:))
title('Davies');
    
    
    
        
