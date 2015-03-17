function [ xshift, yshift ] = feature_matching_homography( I1, I2 )
% THIS FUNCTION IS CURRENTLY NOT WORKING
%feature_matching Matches features in two images
%   Using the vlfeat library, this function takes two images and
%   1. Calculates features in each image.
%   2. Matches the features detected in each image
%   3. Runs the feature points through RANSAC to detect outliers
%       - Pick 4 random feature points from each image
%       - Estimate homography
%       - Homography estimation is described here: http://6.869.csail.mit.edu/fa12/lectures/lecture13ransac/lecture13ransac.pdf
%       - See how good the homography is
%   4. Calculate the xshift and yshift from the best homography found.


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

   
%% RANSAC
% Steps:

numMatches = size(matches,2) ;
X1 = fa(1:2, matches(1,:));
% X1(3,:) = 1;
X2 = fb(1:2, matches(2,:));
% X2(3,:) = 1;
maxInliers = 0;
best_match = [];
numPoints = 4;
threshold = 0.1;

ooo = zeros(1,3);
H = {};
ok = {};
score = {};
for itr = 1:100
    
    % Select 4 feature pairs at random
    cols = randperm(numMatches, numPoints);
    random_match = [matches(:,cols(1)), matches(:,cols(2)), matches(:,cols(3)), matches(:,cols(4))];
    
    x1 = X1(:, cols);
    x2 = X2(:, cols);
    
    % Calculate homography
    H{itr} = homography(x1,x2);
    % Calculate distance to see how good the calculated homography is
    d = calcDist(H{itr}, x1, x2);
    inlier = find(d < 0.1);
	if length(inlier) == 4
        ok{itr} = 1;
        distances{itr} = sum(d);
    else
        ok{itr} = 0;
        distances{itr} = 100000;
    end
    

end


[distances, best] = min(cell2mat(distances));
H = H{best};
ok = ok{best};

xshift = floor(H(2,3));
yshift = floor(H(1,3));

disp(H);
end

function H = homography(p1, p2)


n = size(p1,2);
A = zeros(2*n,9);
A(1:2:2*n,1:2) = p1';
A(1:2:2*n,3) = 1;
A(2:2:2*n,4:5) = p1';
A(2:2:2*n,6) = 1;
x1 = p1(1,:)';
y1 = p1(2,:)';
x2 = p2(1,:)';
y2 = p2(2,:)';
A(1:2:2*n,7) = -x2.*x1;
A(2:2:2*n,7) = -y2.*x1;
A(1:2:2*n,8) = -x2.*y1;
A(2:2:2*n,8) = -y2.*y1;
A(1:2:2*n,9) = -x2;
A(2:2:2*n,9) = -y2;

[eigenvec,~] = eig(A'*A); % Eigen vectors with smalles eigenvals
H = reshape(eigenvec(:,1),[3,3])';
H = H/H(end); % make H(3,3) = 1

end

function d = calcDist(H,p1,p2)
%	Project p1 to PTS3 using H, then calcultate the distances between
%	p2 and PTS3

n = size(p1,2);
p3 = H*[p1;ones(1,n)];
p3 = p3(1:2,:)./repmat(p3(3,:),2,1);
d = sum((p2-p3).^2,1);

end
