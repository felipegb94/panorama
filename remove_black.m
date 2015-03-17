function [ newImg ] = remove_black( I )
%remove_black Removes black padding at the left of the image (and the
%right! or the stitching and feathering will not work perfectly.
%   Detailed explanation goes here

rows = size(I,1);
cols = size(I,2);

middleRow = floor(rows/2);
leftcol = 0;
found = false;

while ~found 
    leftcol = leftcol+1;
    if(I(middleRow, leftcol) ~= 0)
        found = true;      
    end
end

rightcol = cols+1;
found = false;

while ~found
    rightcol = rightcol-1;
    if(I(middleRow, rightcol) ~= 0)
        found = true;
    end
end

newImg = I(:,leftcol:rightcol,:);

%imwrite(newImg, 'cylindrical/image.jpg');

