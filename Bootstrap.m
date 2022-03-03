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
    bot=bootsamples{c};
    for clus_num=1:c+3
        botat=bootstats{c};
        idk= cell(2,nboot);
        lab=index{c,clus_num};
        for n=1:nboot
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
for c=1:5
    for i=1:c+3
        Vec=[];
        q=swap_mat{c,i};
        for j=1:nboot
            Vec(end+1)=q{2,j}(2);
        end
        format = "hist_%0d_kemans_%0d_label .png";
        filename=sprintf(format,c+3,i);
        histogram(Vec);
        saveas(gcf,filename)
    end
end
for c=1:5
    vec=[];
    stab=point_freq{1,c};
    for j=1:length(stab(1,:))
        freq=sum(stab(:,j)==1)/(sum(stab(:,j)==1)+sum(stab(:,j)==-1));
        vec(end+1)=freq;
    end
    format = "freq_%0d_kemans.png";
    filename=sprintf(format,c+3);
    histogram(vec);
    saveas(gcf,filename) 
end
