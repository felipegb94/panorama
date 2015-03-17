 function [ I_cylindrical ] = cylindrical( I, f, padheight )
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

unwrapped = zeros(floor(f), floor(f), 3);


for i = 1:width
    for j = 1:height
        curr_x = i-x_center; %Start at -x_center go to +x_center
        curr_y = j-y_center; %Start at -y_center go to +y_center

        theta = asin(curr_x/(sqrt(curr_x*curr_x + f*f)));
        h = curr_y/(sqrt(curr_x*curr_x + f*f));

        %Find the corresponding x and y coordinate in the unwrapped
        %cylinder
        x_cyl = round(f*theta + x_center);
        y_cyl = round(f*h + y_center);
        unwrapped(y_cyl,x_cyl,:) = I(j,i,:);
    end
end

I_cylindrical = uint8(unwrapped);
pad = zeros(padheight, size(I_cylindrical,2), size(I_cylindrical,3));
I_cylindrical = [pad; I_cylindrical; pad];













