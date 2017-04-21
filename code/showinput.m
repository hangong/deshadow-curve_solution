function showinput(pran)
%SHOWINPUT is the driver for batch shadow removal.
%   SHOWINPUT takes one optional parameters: PRAN is a vector that specifies the 
%   numbers of which images to remove shadow from. The paths of images are
%   defined in datapath.p ('data/original').
%
%   SHOWINPUT shows all shadow images with their input marked
%
%   SHOWINPUT(PRAN) removes shadow from the images in data path specified
%   by their index PRAN in alphabetical order.
%
  
%   Copyright 2015 Han Gong, University of East Anglia
%   Copyright 2014 Han Gong, University of Bath

paths = datapath(true); % add image files to path
[imgs,img_name] = loadimlist(paths); % load image files
len = size(img_name,1); % length of testcases
%ipath = '1in/'; % input path
%opath = '1out/'; % output path
ipath = 'xinputs/'; % input path
opath = '1mark/'; % output path
if ~exist(opath,'dir'), mkdir(opath); end

%% global definition
ran = 1:len;

if nargin>0, ran = pran; end;

for i = ran
    img = im2double(imread([paths{1},'/',imgs{i}])); % input image
    imsk = logical(imread([ipath,img_name{i},'.png'])); % load user input
    rimg = img;
    rimg(:,:,1) = rimg(:,:,1).*(1+0.7*imsk);
    imwrite(rimg,[opath,img_name{i},'.','tif']); % output
end

end
