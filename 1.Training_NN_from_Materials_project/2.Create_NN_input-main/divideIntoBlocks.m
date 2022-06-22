function [dividedImage,num] = divideIntoBlocks(InputImage,Block_x,Block_y)
img1 = InputImage;
Lx=(size(img1,1)/Block_x);Ly=(size(img1,2)/Block_y);
TOTAL_BLOCKS = Lx*Ly;
dividedImage = zeros([Block_x Block_y TOTAL_BLOCKS]);

if rem(size(img1,1),Block_x)==0||rem(size(img1,2),Block_y)==0
    for i=1:Lx
        for j=1:Ly
            dividedImage(:,:,((i-1)*Lx)+j) ...
                = img1(((i-1)*Block_x)+1:(i*Block_x),((j-1)*Block_y)+1:(j*Block_y));
            figure(3)
            subplot(Lx,Ly,((i-1)*Lx)+j),imshow(uint8(dividedImage(:,:,((i-1)*Lx)+j)));
            set(gca,'tag',num2str(((i-1)*Lx)+j))
        end
    end
    num=clicksubplot
    close(figure(3));
else
    fprintf('Block sizes are not right');
end