clc
clear all
nstart=170;nend=170;
nsamples=nend-nstart+1;

block_x=30;block_y=50;
division_x=150/block_x;division_y=250/block_y;

flat_band_index=ones(1,nsamples*(division_x*division_y));
im_mat=zeros(nsamples*(division_x*division_y),(block_x*block_y));
for i=1:nsamples
    fil=strcat('mp-',num2str(nstart+i-1),'_*');
    % load the image files and store in matrix
    lst=dir(fil);
    if size(lst,1)==0
        continue;
    end
    lst.name
    image1 = imread(lst.name);
    image_g=rgb2gray(image1);
    [divided_img,num]=divideIntoBlocks(image_g,block_x,block_y);
    for count=1:division_x*division_y
        imgg=divided_img(:,:,count);
        image_vec=imgg(:);
        im_mat(((i-1)*division_x*division_y)+count,:)=image_vec;
%     siz=size(image_g);
    end
    if num==0
        fprintf('No flat band in this band-structure');
    else
        for num_count=1:length(num)
            flat_band_index(((i-1)*division_x*division_y)+num(num_count))=2;
%       flat_band_index(num)=2;
        end
    end
    (1);
    
    %store flat_band indices
%     fil1=strcat('selected/mp-',num2str(i),'_*');
%     lst1=dir(fil1);
%     if size(lst1,1)==1
%         flat_band_index(i)=2;
%     end
    clear image image_g image_vec lst fil fil1 lst1 divided_img num
end
(1);

null_index=zeros(1,nsamples*division_x*division_y);
for i=1:size(im_mat,1)
    if im_mat(i,:)==zeros(1,block_x*block_y)
        null_index(i)=1;
    end
end
I=find(null_index);

im_mat(I,:) = [];
flat_band_index(I)=[];
X=im_mat;y=flat_band_index;
filename = sprintf('img_data_divided_%d_%d_tr3.mat',nstart,nend);
save(filename,'X','y');
