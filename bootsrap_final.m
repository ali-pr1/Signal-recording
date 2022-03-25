cd 'E:/ALI/processing project/signal recording'
data=readmatrix('shotgun.xlsx', 'NumHeaderLines',1);
data=data(:,[2,3]);
index = cell(5,8);
% labels cells are going to contain cluster labels of each k(initial label
% for bootstrap usage
labels=cell(1,5);
% linear transformation
[Err, P] = fit_2D_data(data(:,1),data(:,2), 'yes');
% clustering Data
X = P(1)*data(:,1);
Y = data(:,2)-P(2);
for c = 2:6
    dataTable = readtable('shotgun.xlsx');
    % Kmeans clustering, cosine metric, for probable suitable candidates
    [idx,C] = kmeans(data,c,'Distance','Cosine','Replicates',5, ...
            'MaxIter',1000);
    label=idx;
    %plot clusters
    figure
    gscatter(data(:,1),data(:,2),idx)
    title(sprintf('k = %d after transformation', c))
    saveas(gcf,sprintf('clustering with linear transformation_%0d.png',c))
    % Add transformed coordinates to excel output
    dataTable.disX=X;
    dataTable.disY=Y;
    dataTable.label=label;
    format = "cosine kmeans_%0d_shotgun_modified .xlsx";
    filename=sprintf(format,c);
    writetable(dataTable,filename)
    d_c = vertcat(label);
    labels{c-1} = d_c;
    for k=1:c
        index{c-1,k}=find(label==k);
    end
        
end
% data frame of interest in bootstrap:
% a matrix for each kmeans of shape nboot * length(data)
% each index can take 3 values:
% 1 means label index of element is unchange in bootstrap
% 0 means the element was not picked during bootstrap
% -1 opposite case of 1
% count number of 1 s and -1 s for each column then calculate the ratio of 1 to sum of 1
% and -1. that would be conservation ratio of element
point_freq = cell(1,5);
for i=1:5
    for j=1:length(data)
        % marking columns with element index
        point_freq{i}(1,j)=j;
    end
end
% this data frames tells us how the initital clusters evolved during      
% bootstraping. especially mode and it's frequency can be useful
% swap_mat is a dataframe which a martix is assigned to eahc cluster in
% each k. shape of matrix is 2* nboot. notice that by cluster i mean the
% initial clusters which we labeled in kmeans not bootstrap
% elements of the first row represents a vector.the vector is label number 
% of elements of cluster in bootstrap clustering. thus mode of each cluster
% is probably the arbitrary index of initial label.
% the second row elements are vectors which first elements are mode of
% corresponding vector in row one and second element is the frequency of
% that mode (check for dangerously low frequencies)
swap_mat = cell(5,8);
bootstats = cell(1,5);
bootsamples = cell(1,5);
nboot = 1000;
for c = 2:6
    [bootstat, bootsam] = bootstrp(nboot,@(x) kmeans(x,c,...
    'Distance','cosine'), data);
    bootstats{c-1} = bootstat;
    bootsamples{c-1} = bootsam;
end
% for loop below is for bootstrap analysis
for c=1:5
    % matrix of choosen elements in bootstrap for a specific k
    % each column represents a bootstrap sample
    bot=bootsamples{c};
    for clus_num=1:c+1
        % matrix of labels of choosen elements in bootstrap for a specific 
        % k. this time each row represents a bootstrap sample
        botat=bootstats{c};
        % idk is a transient variable doesn't really matter by itself. you
        % can thing of it as building blocks of swap_mat
        idk= cell(2,nboot);
        % initial labels (for comparison and fixing the arbitrary labeling
        % assignment
        lab=index{c,clus_num};
        for n=1:nboot
            % X is the vector which forms first row of swap_mat
            X=[];
            for i=1:length(lab)
                for j=1:length(bot(:,n))
                    if bot(j,n)== lab(i)
                        X(end+1)=botat(n,j);
                    end
                end
            end
            idk{1,n} = X;
            M=mode(X);
            idk{2,n}=[M,sum(X==M)/length(X)];
            clear X
            % compute point_freq elements
            for j=1:length(bot(:,n))
                for i=1:length(index{c,clus_num})
                    if bot(j,n)== lab(i)
                        if botat(n,j)==M
                            point_freq{c}(n+1,bot(j,n))=1;
                        else
                            point_freq{c}(n+1,bot(j,n))=-1;
                        end
                    end
                end
            end
        end
        swap_mat{c,clus_num}=idk;
        clear idk
    end
    clear bot
end
