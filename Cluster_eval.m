%% kmeans clustering for "standard curve" data points
%import data
%cd 'E:/ALI/processing project/signal recording'
% trial.xlsx contains natural log of intensities for edited and unedited
% channels
DataA=readmatrix('trial.xlsx', 'NumHeaderLines',1);
DataA=DataA(:,[2,3]);
index = cell(5,8);
labels=cell(1,5);
clust = zeros(size(DataA,1),8);
for c = 2:12
    dataTable = readtable('trial.xlsx','NumHeaderLines',1);
    % 12 clusters was not stable even without bootstraping
    % 11 clusters was not unstable like 12 but it was not appealing so I
    % didn't do any further analysis on it
    % same for 10, 9
    % I started analysis on 4-8 clusters clustering
    [idx,C] = kmeans(DataA,c,'Distance','Cosine','Replicates',5, ...
        'MaxIter',1000);
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

%% evaluation of cluster numbers
eva1 = evalclusters(DataA,clust,'CalinskiHarabasz');
eva2=  evalclusters(DataA,clust,'silhouette','Distance','cosine');
eva3=  evalclusters(DataA,clust,'DaviesBouldin');
eva4=  evalclusters(DataA,'kmeans','gap','Distance','cosine', ...
    'KList',[1:12],'B',500);

%% Plot cluster evaluation results
evals = {eva1, eva2, eva3, eva4};
for i=1:length(evals)
    figure
    plot(evals{i}.InspectedK,evals{i}.CriterionValues, ...
        'k--o', ...
        'LineWidth',1.5, ...
        'MarkerSize',7)
    title({sprintf('cluster evaluation using %s method', ...
        evals{i}.CriterionName); ...
        sprintf('( optimal k = %d )',evals{i}.OptimalK)})
    xlabel('number of clusters')
    ylabel('score')
    saveas(gcf,sprintf('k_evaluation_%s.png',evals{i}.CriterionName))
end