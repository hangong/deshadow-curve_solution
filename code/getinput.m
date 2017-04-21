function getinput(varargin)
%GETINPUT obtains user input
%
% Copyright Han Gong 2014

paths = datapath(true); % add image path
[imgs,img_name] = loadimlist(paths); % load image list
len = size(img_name,1); % length of image list
mpath = ['1inputs/']; % marker path
wz = 6;

if ~exist(mpath,'dir'), mkdir(mpath); end
if nargin==1, lset = varargin{1}; else lset = 1:len; end

for i = lset
    im = im2double(imread(imgs{i}));
    imshow(im); % display image
    imsz = size(im); imhw = imsz(1:2);
    msk = zeros(imhw);
    title('Select Comparable Pixels');
    while true % get the pixels
        [~,x,y] = freehanddraw(gca,'color','r','linewidth',wz); % get xy
        if length(x)>2
            tmsk = xy2msk([x,y]',imhw,wz); % convert xy to mask
            msk = msk + tmsk;
        else break;
        end
    end
    imwrite(msk,[mpath,img_name{i},'.png']);
    close all;
end

datapath(false);

end
