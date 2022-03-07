cd 'E:/ALI/processing project/signal recording'
data=readmatrix('trial.xlsx', 'NumHeaderLines',1);
data=data(:,[2,3]);
index = cell(5,8);
labels=cell(1,5);
[Err, P] = fit_2D_data(data(:,1),data(:,2), 'yes');
X = P(1)*data(:,1);
Y = data(:,2)-P(2);
for c = 2:12
    dataTable = readtable('trial.xlsx');
    % 12 clusters was not stable even without bootstraping
    % 11 clusters was not unstable like 12 but it was not appealing so I
    % didn't do any further analysis on it
    % same for 10, 9
    % I started analysis on 4-8 clusters clustering
    [idx,C] = kmeans([X,Y],c,'Distance','Cosine','Replicates',5, ...
            'MaxIter',1000);
    label=idx;
    figure
    gscatter(X,Y,idx)
    title(sprintf('k = %d after transformation', c))
    saveas(gcf,sprintf('clustering with linear transformation_%0d.png',c))
    dataTable.disX=X;
    dataTable.disY=Y;
    dataTable.label=label;
    format = "cosine kmeans_%0d .xlsx";
    filename=sprintf(format,c);
    writetable(dataTable,filename)
    d_c = vertcat(label);
    labels{c-1} = d_c;
    for k=1:c
        index{c-1,k}=find(label==k);
    end
        
end
% data frame of interest
point_freq = cell(1,11);
for i=1:11
    for j=1:length(data)    
        point_freq{i}(1,j)=j;
    end
end
% this data frames tells us how the initital clusters evolved during      
%bootstraping. especially mode and it's frequency can be useful
swap_mat = cell(11,8);
bootstats = cell(1,11);
bootsamples = cell(1,11);
nboot = 1000;
for c = 2:12
    [bootstat, bootsam] = bootstrp(nboot,@(x) kmeans(x,c,...
    'Distance','cosine'),	[X,Y]);
    bootstats{c-1} = bootstat;
    bootsamples{c-1} = bootsam;
end
% for loop below is for bootstrap analysis
for c=1:11
    bot=bootsamples{c};
    for clus_num=1:c+1
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


%extract plots
cd 'E:/ALI/processing project/signal recording'
nboot=1000;
wt=cell(1,11);
for c=1:11
    A=zeros(nboot,c+1);
    B=zeros(1,nboot);
    for i=1:c+1
        Vec=[];
        q=swap_mat{c,i};
        for j=1:nboot
            Vec(end+1)=q{2,j}(2);
            A(j,i)=q{2,j}(1);
        end
        format = "hist_%0d_kemans_%0d_label .png";
        filename=sprintf(format,c+1,i);
        histogram(Vec);
        saveas(gcf,filename)
    end
    for n=1:nboot
        B(n)=sum(A(n,:)==mode(A(n,:)));
    end
   wt{1,c}=B;     
end
% check if the mode repeats more than once
test=zeros(1,11);
for i=1:length(test)
x=wt{1,i};
test(i)=length(x(x~=1));
end
for c=1:11
    format='cosine kmeans_%0d .xlsx';
    filename=sprintf(format,c+1);
    dataTable = readtable(filename);
    vec=[];
    stab=point_freq{1,c};
    for j=1:length(stab(1,:))
        freq=sum(stab(:,j)==1)/(sum(stab(:,j)==1)+sum(stab(:,j)==-1));
        vec(end+1)=freq;
    end
    format = "freq_%0d_kemans.png";
    filename1=sprintf(format,c+1);
    histogram(vec);
    dataTable.freq=transpose(vec);
    format2='cosine kmeans_%0d_final .xlsx';
    filename2=sprintf(format2,c+1);
    writetable(dataTable,filename2)
    saveas(gcf,filename1) 
end


% choose for any k means with mode repetition
A=zeros(nboot,6);
B=zeros(1,nboot);
C=[];
for i=1:6
    Vec=[];
    q=swap_mat{5,i};
    for j=1:nboot
         Vec(end+1)=q{2,j}(2);
         A(j,i)=q{2,j}(1);
    end
end
for n=1:nboot
    B(n)=sum(A(n,:)==mode(A(n,:)));
    if B(n)>1
        C(end+1)=n;
    end 
end
DataA=readmatrix('cosine kmeans_6 .xlsx', 'NumHeaderLines',1);
j=0;
for i=1:length(C)
    j=j+1;
    format = "6_check_scatter_%0d.png";
    filename=sprintf(format,j);
    U=bootsamples{1,5}(:,C(i));
    D=DataA(U,:);
    Q=transpose(bootstats{1,5}(C(i),:));
    D(:,end+1)=Q;
    subplot(1,2,1);
    gscatter(D(:,2),D(:,3),D(:,end-1));
    title('Old labels');
    subplot(1,2,2);
    gscatter(D(:,2),D(:,3),D(:,end));
    title('New labels');
    saveas(gcf,filename)
    clear D
end
