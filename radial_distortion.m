function [ Inew ] = radial_distortion( I, k1, k2, f )
%% Calculates the radial distortion of the image

Inew = zeros(size(I,1), size(I,2), size(I,3));
x_c = floor(size(I,2)/2);
y_c = floor(size(I,1)/2);

for y = 1:size(Inew,1)
    for x = 1:size(Inew,2)
        xnorm = (x-x_c-1) / f;
        ynorm = (y-y_c-1) / f;
        
        r = sqrt((xnorm)^2 + (ynorm)^2);
        xdistnorm = (xnorm)*(1 + k1*(r^2) + k2*(r^4));
        ydistnorm = (ynorm)*(1 + k1*(r^2) + k2*(r^4));
        
        if xdistnorm < -1 || ydistnorm < -1 || xdistnorm > 1 || ydistnorm > 1
            continue
        end
        
        xdist = ceil(xdistnorm * f + x_c);
        ydist = ceil(ydistnorm * f + y_c);
        
        Inew(y,x,:) = I(ydist,xdist,:);
    end
end

Inew = uint8(Inew);

end

