function [ xshift, yshift ] = feature_matching_scores( I1, I2 )
%feature_matching Matches features in two images
%   Using the vlfeat library, this function takes two images and
%   1. Calculates features in each image.
%   2. Matches the features detected in each image
%   3. Takes the features with the highest scores
%   4. Returns 2 matrices with the x and y coordinates of the features that
%   matched in each image.

im1 = single(rgb2gray(I1));
im2 = single(rgb2gray(I2));

% Compute features for each image
disp('Calculate SIFT feature...');
[fa, da] = vl_sift(im1) ;
[fb, db] = vl_sift(im2) ;

% Check for matches in the features detected. Matches is a 2*n vector.
% Where (1,i) is the column index of the feature in fa that was match to 
% the feature in fb whose column index is (2,i) in matches. 
disp('Calculate Matches using descriptors from SIFT...');
[matches, scores] = vl_ubcmatch(da, db);

% Sort scores from best to worst
disp('Sorting scores and matches...');
[sorted_scores, perm] = sort(scores) ;
% Sort matches from best to worst
sorted_matches = matches(:, perm);
% Take top ten matches
top_matches = sorted_matches(:, 1:10)

figure(1); clf;
subplot(2,1,1)
% Concatenate images
imagesc(cat(2, I1, I2)) ;
subplot(2,1,2)
imagesc(cat(2, I1, I2)) ;

xa = fa(1,top_matches(1,:)) ;
xb = fb(1,top_matches(2,:)) + size(I1,2) ;
ya = fa(2,top_matches(1,:)) ;
yb = fb(2,top_matches(2,:)) ;

hold on ;
h = line([xa ; xb], [ya ; yb]) ;
set(h,'linewidth', 1, 'color', 'b') ;

vl_plotframe(fa(:,top_matches(1,:))) ;
fb(1,:) = fb(1,:) + size(I1,2) ;
vl_plotframe(fb(:,top_matches(2,:))) ;
axis image off ;

% Attempt to stitch images 
dx = xb - xa;
dy = yb - ya;
xshift = floor(mean(dx));
yshift = floor(mean(dy));

    

