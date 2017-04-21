function out = filtres(in)
%FILTRES filters relighted sample and removes mac band artefacts
%
% Copyright Han Gong 2014

h = fspecial('average',[5,1]); % averaging kernel
rs = zeros(size(in)); % scales of band
out = in;
for ch = 1:3
    trs = imfilter(squeeze(in(:,ch,:)),h,'symmetric'); % local filtering
    rs(:,ch,:) = bsxfun(@rdivide,trs,mean(trs)); % error scale
end
tsig = in./rs; % test of smoothing
ov = mean(abs(log(squeeze(mean(tsig,2))))); % original variation
er = mean(abs(log(squeeze(mean(rs,2))))); % variation error
us = ov>er; % samples to smooth if original variation is larger
out(:,:,us) = tsig(:,:,us); % apply smoothing

end

