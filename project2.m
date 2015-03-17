%% CS 766 Project 2 - Panorama
% Isaac Sung and Felipe Gutierrez
%
% Create a panorama picture.
% 
% Steps: Calculate cylindrical projection
%        Crop black edges
%        Use RANSAC to find feature matches and calculate x,y-shifts
%        Align and stitch, use feathering to blend

% Pre processing
disp('Reading Images...');
[images, numImages] = readImages('./images/');

f = 682.05069;
k1 = -0.22892;
k2 = 0.27797;
pad = 500;
images_cyl = cell(1,numImages);

% Maybe unnecessary? Not sure if doing correctly...
disp('Calculating radial distortion...');
for i = 1:numImages
    I_rgb = images{i};
    images_cyl{1,i} = radial_distortion(I_rgb, k1, k2, f);
end

% Calculate cylindrical projections
disp('Calculating cylindrical images...');
for i = 1:numImages
    images_cyl{1,i} = cylindrical_copy(images{1,i}, f, pad);
    images_cyl{1,i} = remove_black(images_cyl{1,i});
    
    % Testing: normalizing images
 %   images_cyl{1,i} = get_exposure_diff(images_cyl{1,i});
end

% TESTING
% feature_matching_copy(images_cyl);
% 
% disp('Calculating 1st xshift and yshift...');
% I1 = images_cyl{numImages};
% I2 = images_cyl{numImages-1};
% [xshift, yshift] = feature_matching_copy(I1, I2);

% disp('Stitching 1st image pair...');
% figure
% currMosaic = stitch(I1,I2,xshift,yshift);
% imshow(currMosaic);

% disp('Constructing test mosaic...');
% im1 = images_cyl{1,18};
% im2 = images_cyl{1,17};
% imwrite(im2, 'im2_test.jpg');
% [xshift,yshift] = feature_matching_copy(im1,im2);
% mosaic = stitch(im1,im2,xshift,yshift,pad);
% imshow(mosaic);
% imwrite(mosaic, 'test.jpg');

% Find x,y-shifts and stitch together
disp('Constructing Mosaic...');
totalyshift = 0;
currMosaic = images_cyl{numImages};
left_middle = ceil(size(images_cyl{numImages},1)/2);

for i = numImages:-1:2
    toStitch1 = images_cyl{1,i};
    toStitch2 = images_cyl{1,i-1};
    % Change feature matching function to feature_matching_scores to get
    % scores results.
    [xshift,yshift] = feature_matching_averageDist(toStitch1, toStitch2);
    totalyshift = totalyshift + yshift;
    currMosaic = stitch(currMosaic, toStitch2, xshift, totalyshift, pad);
    imshow(currMosaic);
end

% Stitch first and last images together to find final alignment
toStitch1 = images_cyl{1};
toStitch2 = images_cyl{numImages};
% Change feature matching function to feature_matching_scores to get
% scores results.
[xshift,yshift] = feature_matching_averageDist(toStitch1, toStitch2);
totalyshift = totalyshift + yshift;
right_middle = ceil((size(images_cyl{numImages},1)/2) + totalyshift);
currMosaic = stitch(currMosaic, toStitch2, xshift, totalyshift, pad);

% Calculate final alignment
disp('Calculating Alignment...')
dx = size(currMosaic,2);
dy = right_middle - left_middle;
slope = dy/dx;

currMosaic = align(currMosaic, slope);

% Crop final image
disp('Cropping...')
currMosaic = crop(currMosaic);

figure
imshow(currMosaic);
imwrite(currMosaic, 'mosaic.jpg');

