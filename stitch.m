function [ newImg ] = stitch( I1, I2, xshift, yshift, pad )
%Stitch Stitches 2 images given an x and y shift.
% 

% ATTEMPTED BUT FAILED
% First match exposures
% I2 = get_exposure_diff(I1, I2, xshift, yshift, pad);

% Feathering weight
count = 0;

newImg = cat(2,I1,I2);
%imwrite(newImg, 'catImg.jpg');
for col = (size(I1,2))+1:1:size(newImg,2)
    for row = pad:1:size(newImg, 1)-pad
        if yshift >= 0
           if col-xshift <= size(I1,2)
               % Feathering
               w = count / double(xshift);
                newImg(row - yshift, col - xshift, :) =...
                    floor(w*newImg(row, col,:) + (1-w)*I1(row-yshift,col-xshift,:));
                
           else
               newImg(row - yshift, col - xshift, :) = newImg(row, col,:);
           end
        else
           if col-xshift <= size(I1,2)
               % Feathering
               w = count / double(xshift);
                newImg(row, col - xshift, :) =...
                    floor(w*newImg(row + yshift, col,:) + (1-w)*I1(row,col-xshift,:));
               
           else
                newImg(row, col - xshift, :) = newImg(row + yshift, col,:);
           end
        end
        
    end
    
    count = count + 1;
end

col = size(I1,2) - xshift + size(I2,2);
newImg = newImg(:, 1:col,:);

end

