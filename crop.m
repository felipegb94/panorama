function [ mosaic ] = crop( mosaic )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

row1 = 0;
row2 = 0;
found1 = false;
found2 = false;
currRow = 1;
while ((~found1))
    currRow = currRow+1;
    if(mosaic(currRow, 1) ~= 0)
        found1 = true;      
    end
end
row1 = currRow;

while ((~found2))
    currRow = currRow+1;
    if(mosaic(currRow, 1) == 0)
        found2 = true;      
    end
end
row2 = currRow;

col = size(mosaic,2);
middle = floor(size(mosaic,1)/2);
found = false;

while ((~found))
    col = col-11;
    if(mosaic(middle, col) ~= 0)
        found = true;      
    end
end

mosaic = mosaic(row1:row2, 1:col, :);

end

