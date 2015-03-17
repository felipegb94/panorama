function [ I2new ] = get_exposure_diff( I1, I2, xshift, yshift, pad )
% Normalizes the images to hopefully adjust to a correct exposure

I2new = zeros(size(I2,1), size(I2,2), size(I2,3));

% Just random numbers
x = 10;
y = pad+200;

% Find the difference in pixel values
ediff = I1(y,size(I1,2)-xshift+x,:) - I2(y-yshift,x,:);

for row = pad:1:size(I2new,1)-pad
    for col = 1:size(I2new,2)
        I2new(row,col,:) = I2(row,col,:) + ediff;
    end
end
end

