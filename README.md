# Panorama

This is Felipe Gutierrez and Isaac Sung's implementation of a panorama / image stitching algorithm. 

## Running the program

Place all images into a subdirectory where the MATLAB source code is stored. Then create a text file called list.txt and write the name each image (including the file extension) on each line. Order them in counter-clockwise order of rotation. Then put the appropriate camera parameters (f, k1, k2). By default it has the appropriate camera parameters to create a panorama of the images in the 'images' folder.

```
f = 682.05069;
k1 = -0.22892;
k2 = 0.27797;
```

### Interactive viewer

In order to look at the results in an interactive viewer, clone the repository and then in your browser go to:

/path/to/repository/html/3D_panorama.html
OR
/path/to/repository/html/2D_panorama.html

In my case the path looked like this: file:///Users/felipegb94/Documents/Septimo%20Semestre/Computer%20Vision/panorama/html/3D_panorama.html 

The 3D panorama lets you see a full screen panorama, however you can only see a certain portion of it at a time. The 2D panorama let's you see the whole mosaic at once.

## Algorithm

### 1) Convert to cylindrical coordinates

In order to make it easier to properly align the multiple images, we project the images onto a cylinder. This converts the rotational problem into a strictly translational problem. We mapped the x,y coordinates of the original image onto a cylinder by using the following formulas:

 ![cylindrical_formula_1.png](https://bitbucket.org/repo/L8gR7z/images/2692749008-cylindrical_formula_1.png)

![cylindrical_formula_2.png](https://bitbucket.org/repo/L8gR7z/images/2133978856-cylindrical_formula_2.png)

![cylindrical_formula_3.png](https://bitbucket.org/repo/L8gR7z/images/2287886039-cylindrical_formula_3.png)

Where z in our case is equal to the focal length, f. We converted each image into cylindrical coordinates to make alignment easier. The implementation for the cylindrical transformation is under 'cylindrical_copy.m'

### 2) Use RANSAC to find feature matches and calculate alignment

We used the MATLAB library [VLFeat](http://www.vlfeat.org/overview/sift.html) to automatically find features in each image. Then, the [RANSAC](http://en.wikipedia.org/wiki/RANSAC) algorithm was used to find the best matching features. We then calculated the x and y coordinate shifts. 

In this step we used three different approaches to find the feature points we used to calculate the x and y shifts. The one that produced the best results were the ones that used RANSAC, however using only the scores produced decent results given the fact that it made way less operations.

1. RANSAC with average distances: Instead of calculating a homography (that would also take into account rotational distance), we used a naive approach of taking the mean of the difference of points between images when searching for matching features. We did this by first selecting a random sample of matching features, then found the average x translation and y translation between all the samples. We then subtracted this x-shift and y-shift from all the other pairs of features and calculated the difference between the two images. This number was then used to determine if a point was an inlier or not. The implementation of this approach is under 'feature_matching_averageDist.m'. This is the function being used by default in the program.

2. RANSAC with homographies: We also tried to implement RANSAC with homographies to calculate the xshift and yshift needed to stitch the images, but were not able to get it to work. The implementation is under the 'feature_matching_homography.m' file. 

3. Vlfeat scores: In this approach we did not use RANSAC algorithm to find outliers, but instead vlfeat library scores. When vlfeat does matching it returns a score for each feature point. So we just sorted the points from best macth to worst match and took the top 10 matches to calculate the xshift and yshift. The implementation of this approach is under 'feature_matching_scores.m'. In order to reproduce the results of this function, change the lines of code in project2.m that call:
```
feature_matching_averageDist(...)
```
to
```
feature_matching_scores(...)
```

### 3) Stitch and crop the shifted images

When stitching together the shifted images, we had to use a feathering technique to blend the two images together to make a seamless stitch. We used the simple formula: 

Inew(i,j) = (1-w)(I1(i,j)) + w(I2(i,j)). 

#### Exposure differences

In order to make up for exposure differences, we tried to equalize pixel values by comparing matching points. However, this did not work out as expected and resulted in the following image:

![mosaic.jpg](https://bitbucket.org/repo/L8gR7z/images/2091586252-mosaic.jpg)

If we had had more time, I would have attempted to implement the methods described in [this paper](http://www.eyemaginary.com/Portfolio/ColorHistogramWarp.html) to match exposures correctly. However, we ran out of time before being able to implement this method.

#### Aligning final image

In order to align the first and last image, we used the linear warping methods suggested. We calculated the change in y in the middle of the last image compared to the first one. By subtracting the middle index of the last image for the middle index of the left image we get the change in y term, then the number of columns in the image would be the change in x term and with this we calculated the slope for the linear warp. With the slope we calculated the number of rows needed to be shift in each column
```
dx = size(currMosaic,2);
dy = right_middle - left_middle;
slope = dy/dx;
```
## Results

Here is the result of our algorithm with a very basic feathering blending and using the average point RANSAC approach:

![mosaic.jpg](https://bitbucket.org/repo/L8gR7z/images/2428387699-mosaic.jpg)

This is the average point RANSAC approach applied to the test images provided:

![testImages_mosaic.jpg](testImages_mosaic.jpg)

This image was produced by the feature matching that didn't use RANSAC but instead it used the score feature of vlfeat. We took the top 10 matches from vlfeat. The results were not as good as RANSAC, but for less computations it produced a relatively good result (as you zoom in a bit more ghosting is produced compared to the other version).

![mosaic.jpg](https://bitbucket.org/repo/L8gR7z/images/1123581137-mosaic.jpg)

Finally we also applied the algorithm only using the scores to the test images. This time the results were not as good as in the previous image. We think that the reason for this is that SIFT detected many outliers in areas where there were trees (repetitive areas) and since we did not use RANSAC to get rid of them, then the xshifts and yshift calculated were not very accurate. On the other hand the buildings aligned decently well here.

![mosaic_testImages_scores.jpg](mosaic_testImages_scores.jpg)

## Credit

We both contributed equally to this project, through pair programming and working independently. However, almost each aspect of the project was looked over and edited by both of us at one point in time.
