function [dividedImage,Lcolumn,Lrow] = divideIntoBlocks_in(InputImage,Block_row,Block_column)
img1 = InputImage;

Lrow=(size(img1,1)/Block_row);
Lcolumn=(size(img1,2)/Block_column);
TOTAL_BLOCKS = Lcolumn*Lrow;

dividedImage = zeros(Block_row, Block_column, TOTAL_BLOCKS);

if rem(size(img1,1),Block_row)==0||rem(size(img1,2),Block_column)==0
    for i=1:Lrow
        for j=1:Lcolumn
            dividedImage(:,:,((i-1)*Lcolumn)+j) ...
                = img1(((i-1)*Block_row)+1:(i*Block_row),((j-1)*Block_column)+1:(j*Block_column));
%             figure(3)
%             subplot(Lrow,Lcolumn,((i-1)*Lcolumn)+j),imshow(uint8(dividedImage(:,:,((i-1)*Lcolumn)+j)));
%             set(gca,'tag',num2str(((i-1)*Lcolumn)+j))
        end
    end
%     waiting;
%     num=clicksubplot
%     close(figure(3));
else
    fprintf('Block sizes are not right');
end