% Read in the input image files from a directory.
%
% Enter the directory name to search for. Must include a .txt file named
% list.txt.

function [list_images, numImages] = readImages(dirName)

    % read the list.txt file and extract strings
    file = fopen(strcat(dirName,'list.txt'));
    numImages = 0;
    imagelist = {};
    filenames = {};
    
    while ~feof(file)
        imagename = textscan(file,'%s',1);
        imagelist = [imagelist imagename];
        if(size(imagename{1},1) ~= 0)
           numImages = numImages + 1;
        end        
    end
    
    for i = 1:numImages
        filenames = [filenames strcat(dirName,imagelist{1,i})];
    end
    
    I = imread(num2str(cell2mat(filenames(1))));
    [rows, cols, z] = size(I);

    %images = zeros(rows, cols, z, numImages);
    %images(:,:,:,1) = I;

    list_images = cell(1,numImages);
    list_images{1,1} = I;

    for i = 2:numImages
        I = imread(num2str(cell2mat(filenames(i))));
        %images(:,:,:,i) = I;
        list_images{1,i} = I;
    end
    