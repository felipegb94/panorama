 function [ I_cylindrical ] = cylindrical( I, f )
% cylindrical - Calculates the cylindrical coordinates of an image.
%   Takes an image RGB values at coordinates X and Y and caclculates the
%   cylindrical coordinates of those RGB values. 
%   
% Input Arguments: I = Image, f = focal length of camera.

width = size(I,2);
height = size(I,1);

% Calculate image center. Middle pixel.
x_center = floor(width/2);
y_center = floor(height/2);

% Set the range of x and y. From -center to center in intervals of 1.
x_range = -1*x_center+1 : 1 : x_center;
% Go from positive to negative so there is no need to transpose in meshgrid.
y_range = -1*y_center+1 : 1 : 1*y_center;

[X, Y, Z] = meshgrid(x_range, y_range, f);

% Map coordinates to surface of cylinder.
map = 1 ./(sqrt((X.^2) + f*f));
X_hat = X.*map; % X_hat = sin(theta)
Y_hat = Y.*map; % Y_hat = height = h
Z_hat = Z.*map; % Z_hat = cos(theta)

theta = asin(X_hat); % theta in radians
h = Y_hat;

unwrapped = zeros(f, f);
unwrapped_width = size(unwrapped,2);
unwrapped_height = size(unwrapped,1);

x_cyl_center = floor(unwrapped_width/2);
y_cyl_center = floor(unwrapped_height/2);


%%EVERYTHING TILL THIS LINE KIND OF MAKES SENSE.
x_cyl = round(f.*tan(theta) + x_cyl_center);
y_cyl = round(f.*h .* sec(theta) + y_cyl_center);

for i = 1:size(y_cyl, 1)
    for j = 1:size(x_cyl, 2)
        y = y_cyl(i,1);
        x = x_cyl(1,j);
        unwrapped(y,x) = I(i,j);
%         if(x >= width && y>=height)
%             unwrapped(y,x) = I(height,width); 
%         elseif(x >= width)
%             unwrapped(y,x) = I(y,width);
%         elseif (y >= height)
%             unwrapped(y,x) = I(height,x);
%         else
%             unwrapped(y,x) = I(y,x);    
%         end
    end
end

I_cylindrical = unwrapped;









