cd 'E:/ALI/processing project/signal recording'
DataA=readmatrix('trial.xlsx');
DataA=DataA(:,[2,3]);
index = cell(5,8);
labels=cell(1,5);
for c = 4:8
    dataTable = readtable('trial.xlsx');
    % 12 clusters was not stable even without bootstraping
    % 11 clusters was not unstable like 12 but it was not appealing so I
    % didn't do any further analysis on it
    % same for 10, 9
    % I started analysis on 4-8 clusters clustering
    [idx,C] = kmeans(DataA,c,'Distance','Cosine');
    label=idx;
    figure
    gscatter(DataA(:,1),DataA(:,2),idx)
    dataTable.label=label;
    figure;
    gscatter(DataA(:,1),DataA(:,2),idx)
    format = "cosine kmeans_%0d .xlsx";
    filename=sprintf(format,c);
    writetable(dataTable,filename)
    d_c = vertcat(label);
    labels{c-3} = d_c;
    for k=1:c
        index{c-3,k}=find(label==k);
    end
        
end
% data frame of interest
point_freq = cell(1,5);
for i=1:5
    for j=1:length(DataA)    
        point_freq{i}(1,j)=j;
    end
end
% this data frames tells us how the initital clusters evolved during      
%bootstraping. especially mode and it's frequency can be useful
swap_mat = cell(5,8);
bootstats = cell(1,5);
bootsamples = cell(1,5);
nboot = 1000;
for c = 4:8
    [bootstat, bootsam] = bootstrp(nboot,@(x) kmeans(x,c,...
    'Distance','cosine'),DataA);
    bootstats{c-3} = bootstat;
    bootsamples{c-3} = bootsam;
end
% for loop below is for bootstrap analysis
for c=1:5
    bot=bootsamples{c+3};
    for clus_num=1:c+3
        idk= cell(2,nboot);
        % initial cluster members
        lab=index{c,clus_num};
        for n=1:nboot
            % this vector contains label number of each cluster elements
            % after bootstrap
            X=[];
            for i=1:length(lab)
                for j=1:length(bot(:,n))
                    if bot(j,n)== lab(i)
                        X(end+1)=bootstats{c,clus_num}(n,j);
                    end
                end
            end
            idk{1,n} = X;
            M=mode(X);
            idk{2,n}=[M,sum(X==M)/length(X)];
            clear X
            for j=1:length(bot(:,n))
                for i=1:length(index{c,clus_num})
                    if bot(j,n)== index{c,clus_num}(i)
                        if bootstats{c,clus_num}(n,j)==M
                            point_freq{c}(n+1,bot(j,n))=1;
                        else
                            point_freq{c}(n+1,bot(j,n))=0;
                            % add the count 1 for each row and divide by
                            % length of each row. that percentage is what
                            % we want
                        end
                    end
                end
            end
        end
        swap_mat{c,clus_num}=idk;
        clear idk
    end
end
