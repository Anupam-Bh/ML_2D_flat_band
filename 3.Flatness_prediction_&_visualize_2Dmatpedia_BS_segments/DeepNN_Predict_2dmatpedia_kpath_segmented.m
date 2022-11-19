%% This code is for the following operation

% Downloaded band-structure image from 2dmatpedia >> Put into chosen model >> See output in band-strututre and save output matrix

%clc
clear all
close all
%% details of the data to be visualized
block_column=96;block_row=96;
nstart=13;nend=13;
flatness_criteria=0.5  % Keeping 0.5 as flatness criteria
%% load the image files and store in matrix
nsamples=nend-nstart+1;
image_mat = [];         %zeros(30,50,1,nend);
div_mat=[];
mat_id=[];
missing=zeros(nsamples,1);
tic;
for i=1:nsamples
    fil=strcat('2dm-',num2str(nstart+i-1),'.png');
    lst=dir(fil);
    if size(lst,1)==0
        missing(i)=1;
        continue;
    end
    if mod(i,100)==0
        fprintf('%d\n',i);
        toc;
    end
    lst.name;
    image1 = imread(lst.name);
    image_g=rgb2gray(image1);
    [divided_img,Lcolumn,Lrow]=divideIntoBlocks_in(image_g,block_row,block_column);
    divisions=Lcolumn*Lrow;
    div_mat=[div_mat; divisions Lrow Lcolumn];
    mat_id=[mat_id;convertCharsToStrings(fil)];
    for count=1:divisions
        imgg=divided_img(:,:,count);
        image_mat(:,:,1,size(image_mat,4)+1)=uint8(imgg);
%         image_vec=imgg(:);
%         im_mat=[im_mat;image_vec'];
    end
    clear image image_g image_vec lst fil fil1 lst1 divided_img num Lcolumn Lrow divisions
    
end
image_mat(:,:,:,1)=[];
% image_mat=reshape(im_mat',30,50,1,size(im_mat,1));
%% get output

% for single network
% load('first_model.mat');
% out=first_model(im_mat');

% for averaging out a number of networks
% load chosen_net_skewed_1_5000.mat
load ../../MAT_PROJ/nural_net_code/NN_nntool_good/DeepNN_matlab/deep12_adam_2conv_2sig_2fc_96-96input_10iter_92_1perc.mat;
% for i=1:length(chosen_indices)
%     neti=selected_net_skewed{i};
%     outi(:,:,i)=neti(im_mat');
% end
% out=sum(outi,3)/size(outi,3);
% [M,I] = max(out,[],1);
clear testtarget testset trainset traintarget 
outpred=predict(net,image_mat);
outpred(outpred>1)=1;outpred(outpred<0)=0;
out=zeros(2,size(outpred,1));
for i=1:size(outpred,1)
%     if mod(i,1000)==0
%         fprintf('%d',i);
%     end
    out(1,i)=1-outpred(i);
    out(2,i)=outpred(i);
end


%Overall prediction
pred=zeros(1,length(mat_id));
max_flat=zeros(1,length(mat_id));
flat_div={};
flatness_score=zeros(1,length(mat_id));
for i=1:length(mat_id)
%     if mod(i,200)==0
%         fprintf('%d',i);
%     end
    id_start=sum(div_mat(1:(i-1),1));
    if max(out(2,id_start+1:id_start+div_mat(i,1))) > flatness_criteria  % flatness criteria
        pred(i)=1;
    end
    flat_div{i}=out(2,id_start+1:id_start+div_mat(i,1));
    max_flat(i)=max(out(2,id_start+1:id_start+div_mat(i,1)));
    flatness_score(i)=sum(out(2,id_start+1:id_start+div_mat(i,1)));
end

fprintf('Overall prediction is saved in the matrix "Overall_prediction"\n');
fprintf('The first column gives out the 2dmatpedia indices\n');
fprintf('Second column value 1 denotes a material with flat band\n');
fprintf('The third column of cells show the output of the prediction for each segments in the BS\n');
fprintf('The fourth column shows the flatness scores\n');
fprintf('Fifth column shows the maximum predicted flatness\n');

Overall_pred={mat_id pred' flat_div' flatness_score' max_flat'};
fprintf('Out of %d materials analyzed, %d materials have flat bands',length(pred),length(find(pred==1)));
% save ('Overall_prediction_ML_1_6500_DeepNN_10_10_2022','Overall_pred');
%% visualize the output and bands
% Red box shows segments with predicted flat bands

for i=1:length(mat_id)
    figure(4)
%     H=tiledlayout(div_mat(i,2),div_mat(i,3),'TileSpacing','none');
    for j=1:div_mat(i,1)
        H=subplot(div_mat(i,2),div_mat(i,3),j);
%         tiledlayout(div_mat(i,2),div_mat(i,3),'TileSpacing','none');
        id_start=sum(div_mat(1:(i-1),1));
        imshow(uint8(image_mat(:,:,1,id_start+j)));
        set(H,'box','on','Visible','on','LineWidth',0.5,'XColor','black','YColor','black','xtick',[],'ytick',[]);
        if out(2,id_start+j) > flatness_criteria
            text(10,-10,string(out(2,id_start+j)));
            set(H,'box','on','Visible','on','LineWidth',2,'XColor','red','YColor','red','xtick',[],'ytick',[]);
        end
    end
    if pred(i)==1
        title([mat_id(i),"it has flat bands"]);
    elseif pred(i)==0
        title([mat_id(i),"it does not have flat bands"]);
    end
%     tiledlayout(div_mat(i,2),div_mat(i,3),'TileSpacing','compact');
    waiting;
    close(figure(4));
end
