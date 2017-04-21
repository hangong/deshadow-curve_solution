function rimg = deshadow(im,simsk) % lxy sxy
%DESHAOW removes shadow from input image
%
% Copyright Han Gong 2014

global deb;
imsz = size(im); imhw = imsz(1:2); % image size

%% detect illumination
if deb, disp('detect illumination...'); end
fu = optfuse(im,simsk); % get fusion image and parameter

%% detect rough shadow mask
if deb, toc; disp('detect rough shadow mask...'); tic; end
smsk = getrmask(im,simsk); % get shadow mask

%% sparse scale estimation
if deb, toc; disp('intensity sampling...'); tic; end
% get shadow boundary
bd = getbd(smsk,ceil(max(imhw)/128));
% get two ends of sampling lines
bl = bdspln(fu,smsk,bd,10);
% sample and select valid signals
[bd.t,bl] = spsig(bl,bd.t,im);

if deb, toc; disp('sparse scale estimation...'); tic; end
% Fit intensity and align
[bl,bd] = fitsig(bl,bd);

%% propogate shadow scale field
if deb, toc; disp('propogate shadow scale field...'); tic; end
[imsc,msk] = ppgsf(bl,bd,smsk);

%% relight image
rimo = min(im./min(imsc,1),1);

%% align colour
if deb, toc; disp('align colour...'); tic; end
% start colour alignment
rimg = colaln(rimo,msk,imsc);
%rimg = rimo; % to disable colour alignment
rimgsc = im./rimg;

if deb
    figure('Name','Comparision of Colour Alignment');
    subplot(4,2,1);imshow(im);title('original');
    subplot(4,2,2);imshow(double(smsk));title('rough shadow mask');
    subplot(4,2,3);imshow(fu);title('original illumination layer');
    subplot(4,2,5);imshow(imsc);title('shadow scale matte');
    subplot(4,2,6);imshow(rimgsc);title('adjusted scale matte');
    subplot(4,2,7);imshow(rimo);title('relighted')
    subplot(4,2,8);imshow(rimg);title('adjusted');
end

end

