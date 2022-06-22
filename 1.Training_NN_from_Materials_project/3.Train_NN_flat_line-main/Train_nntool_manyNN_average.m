clc
clear all
close all

%% Load data
% load('img_data_divided_1_500.mat');X1=X';y1=y;clear X y;
% load('img_data_divided_500_1000.mat');X2=X';y2=y;clear X y;
% load('img_data_divided_1000_1500.mat');X3=X';y3=y;clear X y;
% load('img_data_divided_1500_2000.mat');X4=X';y4=y;clear X y;
% load('img_data_divided_2000_2200.mat');X5=X';y5=y;clear X y;
% load('img_data_divided_2200_2500.mat');X6=X';y6=y;clear X y;
% load('img_data_divided_2500_3000.mat');X7=X';y7=y;clear X y;
% load('img_data_divided_3000_3500.mat');X8=X';y8=y;clear X y;
% load('img_data_divided_3500_4000.mat');X9=X';y9=y;clear X y;
% load('img_data_divided_4000_5000.mat');X10=X';y10=y;clear X y;
% 
% % y_a=[y1 y2 y3 y4];
% % X_all=[X1 X2 X3 X4];
% 
% y_a=[y1 y2 y3 y4 y5 y6 y7 y8 y9 y10];X_all=[X1 X2 X3 X4 X5 X6 X7 X8 X9 X10];
load('img_data_divided_1000_2000_tr1.mat');X1=X';y1=y;clear X y;
load('img_data_divided_1000_2000_tr2.mat');X2=X';y2=y;clear X y;
load('img_data_divided_1000_2000_tr3.mat');X3=X';y3=y;clear X y;
y1_avg=round((y1+y2+y3)/3);
load('img_data_divided_1000_2000_tr1.mat');X4=X';y4=y;clear X y;
load('img_data_divided_1000_2000_tr2.mat');X5=X';y5=y;clear X y;
load('img_data_divided_1000_2000_tr3.mat');X6=X';y6=y;clear X y;
y4_avg=round((y4+y5+y6)/3);
load('img_data_divided_2000_3000_tr1.mat');X7=X';y7=y;clear X y;
load('img_data_divided_2000_3000_tr2.mat');X8=X';y8=y;clear X y;
load('img_data_divided_2000_3000_tr3.mat');X9=X';y9=y;clear X y;
y7_avg=round((y7+y8+y9)/3);
load('img_data_divided_3000_4000_tr1.mat');X10=X';y10=y;clear X y;
load('img_data_divided_3000_4000_tr2.mat');X11=X';y11=y;clear X y;
load('img_data_divided_3000_4000_tr2.mat');X12=X';y12=y;clear X y;
y10_avg=round((y10+y11+y12)/3);
load('img_data_divided_4000_5000_tr1.mat');X13=X';y13=y;clear X y;
load('img_data_divided_4000_5000_tr2.mat');X14=X';y14=y;clear X y;
load('img_data_divided_4000_5000_tr3.mat');X15=X';y15=y;clear X y;
y13_avg=round((y13+y14+y15)/3);
X_all=[X1 X4 X7 X10 X13];y_a=[y1_avg y4_avg y7_avg y10_avg y13_avg];
clear y1 y2 y3 y4 y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12 X13 X14 X15

%% Skewness reduction  % This may be used to reduce percentage of negative examples in the trainset
% y1=y_a;X1=X_all;
% yy=find(y_a==1);
% y_a(yy(1:24055))=[];X_all(:,yy(1:24055))=[];


%% Changing 1D target to columns of binary targets
y_all=zeros(2,length(y_a));
aa=find(y_a==1);y_all(1,aa)=1;
bb=find(y_a==2);y_all(2,bb)=1;
clear aa bb y_a yy;


%% training data division
Q=size(y_all,2);
ntrain=floor(Q*0.85);
ntest=Q-ntrain;
ind = randperm(Q);
indtrain = ind(1:ntrain);
indtest = ind(ntrain + (1:ntest));
trainset=X_all(:,indtrain);
traintarget=y_all(:,indtrain);
testset=X_all(:,indtest);
testtarget=y_all(:,indtest);
clear Q ind indtrain indtest ntrain ntest
% NN.divideParam.trainRatio = 0.83;
% NN.divideParam.valRatio   = 0.17;
% NN.divideParam.testRatio  = 0.0;

%% training with patternnet tool
trainf=['trainscg';'traincgb';'traincgf';'traincgp';'trainoss';'traingdx'];
% trainf='trainscg';
count=0;
for i=100
    for j=1:size(trainf,1)
        for k=0.05:0.05:0.25
            count=count+1;
            NN=patternnet([i]);
            NN.divideParam.trainRatio = 0.83;
            NN.divideParam.valRatio   = 0.17;
            NN.divideParam.testRatio  = 0.0;
            NN.trainFCN=trainf(j,:);
            NN.performFCN='crossentropy';
            NN.trainparam.epochs=2000;
            NN.trainparam.goal=0.001;
            NN.trainparam.lr=0.01;
            NN.trainParam.max_fail = 100 ;
            NN.performParam.regularization = k;
            network{count}=train(NN,trainset,traintarget);
            param{count}={i,trainf(j,:),k};           
            ni=network{count};
            yout(:,:,count)=ni(testset);
            [a,b,c,d]=prfmnc(testtarget,yout(:,:,count));
            perf(count,:)=[a b c d]
            clear NN ni a b c d;
        end
    end
end
save('Final_out_1_5000_skewed','network','param','perf');
save('data_1_5000_skewed','trainset','traintarget','testset','testtarget');
% save('Final_out_1_5000_non-skewed','network','param','perf');
% save('data_1_5000_non-skewed','trainset','traintarget','testset','testtarget');
