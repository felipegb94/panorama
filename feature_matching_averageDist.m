function [ xshift, yshift ] = feature_matching_averageDist( I1, I2 )
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

figure(1); clf;
subplot(2,1,1)
% Concatenate images
% imagesc(cat(2, I1, I2)) ;
% subplot(2,1,2)
% imagesc(cat(2, I1, I2)) ;

   
%% RANSAC
% Steps:

numMatches = size(matches,2) ;
maxInliers = 0;
best_match = [];
epsilon = 2;

for itr = 1:10000
    % Select 4 feature pairs at random
    cols = randperm(numMatches, 12);
    random_match = matches(:,cols);

    % Compute homography
    % Take average of all translations
    xa = fa(1, random_match(1,:));
    xb = fb(1, random_match(2,:)) + size(I1,2);
    ya = fa(2, random_match(1,:));
    yb = fb(2, random_match(2,:));
    xshift = mean(xb-xa);
    yshift = mean(yb-ya);
    
    % Compute inliers where SSD(pi', Hpi) < threshold
    xnew = fb(1, matches(2,:)) + size(I1,2) - xshift;
    ynew = fb(2, matches(2,:)) - yshift;
    xdiff = xnew - fa(1, matches(1,:));
    ydiff = ynew - fa(2, matches(1,:));
    inliers = 0;
        
    for i = 1:size(xdiff,2)
        if abs(xdiff(1,i)) < epsilon && abs(ydiff(1,i)) < epsilon
            inliers = inliers + 1;
        end
    end
    
    % Record the largest set of inliers so far
    if inliers > maxInliers
        maxInliers = inliers;
        best_match = random_match(:,:);
    end

end

% Re-compute least squares H estimate on the largest set of the inliers
xa = fa(1, best_match(1,:));
xb = fb(1, best_match(2,:)) + size(I1,2);
ya = fa(2, best_match(1,:));
yb = fb(2, best_match(2,:));
xshift = floor(mean(xb-xa));
yshift = floor(mean(yb-ya));

