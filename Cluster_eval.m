cd 'E:/ALI/processing project/signal recording'
DataA=readmatrix('trial.xlsx');
DataA=DataA(:,[2,3]);
index = cell(5,8);
labels=cell(1,5);
clust = zeros(size(DataA,1),8);
for c = 2:12
    dataTable = readtable('trial.xlsx');
    % 12 clusters was not stable even without bootstraping
    % 11 clusters was not unstable like 12 but it was not appealing so I
    % didn't do any further analysis on it
    % same for 10, 9
    % I started analysis on 4-8 clusters clustering
    [idx,C] = kmeans(DataA,c,'Distance','Cosine');
    label=idx;
    clust(:,c-1)=label;
    dataTable.label=label;
    figure
    gscatter(DataA(:,1),DataA(:,2),idx)
    %format = "cosine kmeans_%0d .xlsx";
    %filename=sprintf(format,c);
    %writetable(dataTable,filename)
    d_c = vertcat(label);
    labels{c-1} = d_c;
    for k=1:c
        index{c-1,k}=find(label==k);
    end
        
end
eva1 = evalclusters(DataA,clust,'CalinskiHarabasz');
eva2=  evalclusters(DataA,clust,'silhouette','Distance','cosine');
eva3=  evalclusters(DataA,clust,'DaviesBouldin');
A=zeros(11,4);
A(:,1)=eva1.InspectedK;
A(:,2)=eva1.CriterionValues;
A(:,3)=eva2.CriterionValues;
A(:,4)=eva3.CriterionValues;
B=[string(eva1.CriterionName),string(eva2.CriterionName),string(eva3.CriterionName)];
for i=2:4
        format = "elbow_%s .png";
        filename=sprintf(format,B(i-1));
        plot(A(:,1),A(:,i));
        saveas(gcf,filename)
end
