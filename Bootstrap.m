cd 'E:/ALI/processing project/signal recording'
DataB=readmatrix('trial.xlsx');
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
        for i=1:length(index{c-1,k})
             index{c-1,k}(i,2)=DataB(index{c-1,k}(i,1),4);
        end
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
