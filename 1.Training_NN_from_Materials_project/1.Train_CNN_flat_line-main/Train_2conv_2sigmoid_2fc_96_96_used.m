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
%cd ../data/
load('img_data_divided_1_1000_tr1.mat');X1=X';y1=y;clear X y;
load('img_data_divided_1_1000_tr2.mat');X2=X';y2=y;clear X y;
load('img_data_divided_1_1000_tr3.mat');X3=X';y3=y;clear X y;
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
X_all_old=[X1 X4 X7 X10 X13];
y_a=[y1_avg y4_avg y7_avg y10_avg y13_avg];
clear y1 y2 y3 y4 y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12 X13 X14 X15



%% Skewness reduction
% y1=y_a;X1=X_all_old;
% yy=find(y_a==1);
% y_a(yy(1:24055))=[];X_all_old(:,yy(1:24055))=[];

%% Changing 1D target to columns of binary targets
y_aa=y_a-1;
y_all=y_aa;
% y_all=categorical(y_aa);
% y_all=zeros(length(y_a),2);
% aa=find(y_a==1);y_all(aa,1)=1;
% bb=find(y_a==2);y_all(bb,2)=1;
% y_all=categorical(y_aa);
%clear aa bb y_a yy;

%% Resize downloaded image to 96X96
X_all=reshape(X_all_old,30,50,1,size(X_all_old,2));
lcol=96;
lrow=96;
X_all_large=zeros(lrow,lcol,1,size(X_all,4));
for n=1:size(X_all,4)
    X_all_large(:,:,1,n)=imsharpen(imresize(uint8(X_all(:,:,:,n)),[lrow,lcol]),'Radius',2,'Amount',1,'Threshold',0);
    
end

%% training data division
Q=size(y_all,2);
ntrain=floor(Q*0.85);
ntest=Q-ntrain;
ind = randperm(Q);
indtrain = ind(1:ntrain);
indtest = ind(ntrain + (1:ntest));
trainset=X_all_large(:,:,:,indtrain);
% traintarget=y_all(indtrain,:);
traintarget=y_all(indtrain);
testset=X_all_large(:,:,:,indtest);
% testtarget=y_all(indtest,:);
testtarget=y_all(indtest);
clear Q ind indtrain indtest ntrain ntest
% NN.divideParam.trainRatio = 0.83;
% NN.divideParam.valRatio   = 0.17;
% NN.divideParam.testRatio  = 0.0;

%% DeepNN
layers = [
    imageInputLayer([lrow lcol 1],"Name","imageinput")
    %resize2dLayer("Name","resize-output-size","GeometricTransformMode","half-pixel","Method","nearest","NearestRoundingMode","round","OutputSize",[28 28])
    %sigmoidLayer("Name","sigmoid1")
    
    convolution2dLayer([10 10],30,"Name","conv_1")
    %reluLayer("Name","relu1")
    %maxPooling2dLayer([3 3],"Name","maxpool1",'Stride',[2 2])
    sigmoidLayer("Name","sigmoid1")
    %softmaxLayer("Name",'softmax1')
    convolution2dLayer([3 3],12,"Name","conv_2")
    %sigmoidLayer("Name","sigmoid2")
    %softmaxLayer("Name",'softmax2')
    %reluLayer("Name","relu2")
    %maxPooling2dLayer([3 3],"Name","maxpool2",'Stride',[2 2])
    %convolution2dLayer([5 5],50,"Name","conv_3")
    %reluLayer("Name","relu3")
    %maxPooling2dLayer([3 3],"Name","maxpool3",'Stride',[2 2])
    %convolution2dLayer([3 3],50,"Name","conv_4")
    %reluLayer("Name","relu4")
    %maxPooling2dLayer([3 3],"Name","maxpool4",'Stride',[2 2])
    fullyConnectedLayer(80,"Name","fc_1")
    %softmaxLayer("Name",'softmax3')
    %reluLayer("Name","relu5")
    sigmoidLayer("Name","sigmoid3")
    %fullyConnectedLayer(30,"Name","fc_2")
    fullyConnectedLayer(1,"Name","fc_3")
    %sigmoidLayer("Name","sigmoid4")
    %classificationLayer('Name','classoutput')
    regressionLayer('Name','regoutput')
    ];
%analyzeNetwork(layers)
% plot(layerGraph(layers));
options = trainingOptions('adam','InitialLearnRate',0.00005,'L2Regularization',0.003,'OutputNetwork','best-validation-loss','MaxEpochs',10,'LearnRateSchedule','none','Verbose',1, ...
    'Plots','training-progress','ExecutionEnvironment','auto','shuffle','every-epoch',ValidationData={testset,testtarget'},ValidationFrequency=300);
% options = trainingOptions('rmsprop','InitialLearnRate',0.0001,'Verbose',1, ...
%     'ExecutionEnvironment','parallel','shuffle','every-epoch',ValidationData={testset,testtarget'},ValidationFrequency=300);
net = trainNetwork(trainset,traintarget',layers,options);

cd ../DeepNN_matlab/
save('deep12_adam_2conv_2sig_2fc',"net","options","layers","trainset","traintarget","testset","testtarget")
testpred=predict(net,testset);
testpred_binary=round(testpred);
testpred_binary(testpred_binary>1)=1;
[tp,tn,fp,fn]=prfmnc(testtarget,testpred_binary')
