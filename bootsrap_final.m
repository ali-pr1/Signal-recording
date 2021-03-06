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
    [idx,C] = kmeans([X,Y],c,'Distance','Cosine','Replicates',5, ...
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
%extract plots
wt=cell(1,5);
for c=1:5
    A=zeros(nboot,c+3);
    B=zeros(1,nboot);
    for i=1:c+3
        Vec=[];
        q=swap_mat{c,i};
        for j=1:nboot
            Vec(end+1)=q{2,j}(2);
            A(j,i)=q{2,j}(1);
        end
        format = "hist_%0d_kemans_%0d_label .png";
        filename=sprintf(format,c+3,i);
        histogram(Vec);
        saveas(gcf,filename)
    end
    for n=1:nboot
        B(n)=sum(A(n,:)==mode(A(n,:)));
    end
   wt{1,c}=B;     
end
% check if the mode repeats more than once
test=zeros(1,5);
for i=1:length(test)
x=wt{1,i};
test(i)=length(x(x~=1));
end
for c=1:5
    format='cosine kmeans_%0d .xlsx';
    filename=sprintf(format,c+3);
    dataTable = readtable(filename);
    vec=[];
    stab=point_freq{1,c};
    for j=1:length(stab(1,:))
        freq=sum(stab(:,j)==1)/(sum(stab(:,j)==1)+sum(stab(:,j)==-1));
        vec(end+1)=freq;
    end
    format = "freq_%0d_kemans.png";
    filename1=sprintf(format,c+3);
    histogram(vec);
    dataTable.freq=transpose(vec);
    format2='cosine kmeans_%0d_final .xlsx';
    filename2=sprintf(format2,c+3);
    writetable(dataTable,filename2)
    saveas(gcf,filename1) 
end

for u=1:5
    format='cosine kmeans_%0d_final .xlsx';
    filename=sprintf(format,u+3);
    dataTable = readmatrix(filename);  
    x=dataTable(:,2);
    y=dataTable(:,3);
    z=dataTable(:,5);
    c=dataTable(:,6);
    scatter3(x,y,z,8,c,'filled')
    colorbar
    colormap cool
    format = "scatter_%0d_kemans.fig";
    filename=sprintf(format,u+3);
    saveas(gcf,filename)
end


% stack bar plots:
stack=cell(5,1);
vec=[0.0, 0.083333333, 0.166666667,0.25,0.333333333,0.416666667,0.5,0.583333333,0.666666667,0.75,0.833333333,0.916666667,1.0];
for c = 4:8
    D=zeros(c,13);
    for k=1:c
        for j=1:13
            freq=vec(j);
            A=sum(index{c-1,k}(:,2)==freq);
            D(k,j)=A;
        end
     stack{c-3,1}=D;
    end
end
for i=1:5
 U=stack{i,1};
 format = "stacked_%0d_kemans.fig";
 filename=sprintf(format,i+1);
 figure
 bar(U,'stacked');
 %ylim([0 14000])
 title(sprintf('%d kmeans cluster ratios',i+1));
 legend(string(1:i+1),'Location','bestoutside')
 saveas(gcf,filename)
end
