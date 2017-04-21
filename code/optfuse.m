function [fu,fv] = optfuse(dimg,mask)
%OPTFUSE produces a fusion image
%
% Copyright Han Gong 2014

imhw = size(mask);
% convert colour spaces and get layers
ycc = rgb2ycbcr(dimg);

num = 3;
candi = zeros([imhw,num]);

% normalise layer value
candi(:,:,1) = ycc(:,:,1);
candi(:,:,2) = 1-ycc(:,:,2);
candi(:,:,3) = ycc(:,:,3);

% compute linear fusion weights
fv = zeros(num,1);
for i = 1:num
    tmp = candi(:,:,i);
    fv(i) = std2(tmp(mask))/std2(tmp);
end

fv = fv.^-3; fv = fv/sum(fv); % compute converted non-linear fusion weights

ofu = zeros(imhw);
for i = 1:num, ofu = ofu + fv(i)*candi(:,:,i); end % do colour fusion

fu = medfilt2(ofu,[10,10]); % apply medium filter to fusion layer

% check if the intensity is inverted.
%dm = mean(fu(mask)); % mean of shadow intensity
%lm = mean(fu(~mask)); % mean of lit intensity

%if (dm>lm)
%    fu = max(fu(:)) - fu;
%end

end

