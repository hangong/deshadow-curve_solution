function out = colaln(in,msk,sc)
%COLALN performs colour transfer to correct artefacts
%
% Copyright Han Gong 2015
global deb

imsz = size(in); imhw = imsz(1:2); imel = imhw(1)*imhw(2);
%% compute transfer function
% create masks
be_i = strel('disk',30); expmask = imdilate(msk.p,be_i);
sasmask = and(expmask,msk.s); satmask = and(expmask,msk.l);

% index of umbra, umbra-side tiny boundary, lit side tiny boundary
sidx = find(~msk.l); usidx = find(sasmask); lsidx = find(satmask);

fin = zeros(size(in));
cin = RGB2Lab(in);

for ch = 1:3, fin(:,:,ch) = bFilter(cin(:,:,ch)); end % filter image
ein = cin-fin; % variation image
rein = ein; % corrected variation image
rstd = zeros(3,1); cout = cin;
for ch = 1:3
    os = (ch-1)*imel;
    % brightness adjustment
    rstd(ch) = mad(ein(lsidx+os),1)/mad(ein(usidx+os),1); % compute std ratio
    tidx = sidx+os;
    rein(tidx) = rstd(ch)*ein(tidx); % just to accomodate debug information
    cout(tidx) = fin(tidx)+rein(tidx);
end
aout = im2double(Lab2RGB(cout)); % initial colour corrected image

%% scale-based regularisation
out = zeros(imsz); % final blended colour corrected image
for ch = 1:3
    tsc = sc(:,:,ch);
    msc = prctile(tsc(:),0.05); % find 5% percentile minimum
    nsc = (tsc-msc)/(1-msc); nsc = max(nsc,0); % normalised scales
    out(:,:,ch) = in(:,:,ch).*nsc + aout(:,:,ch).*(1-nsc); % blending
end

if deb
    figure; title('Gradual Colour Correction');
    subplot(1,6,1); title('Original');
    imshow(in);
    subplot(1,6,2); title('Filtered');
    imshow(Lab2RGB(fin)); 
    subplot(1,6,3); title('Variation');
    imshow(Lab2RGB(abs(ein)));
    subplot(1,6,4); title('Aligned Variation'); 
    imshow(Lab2RGB(abs(rein)));
    subplot(1,6,5); title('Corrected'); 
    imshow(aout);
    subplot(1,6,6); title('Blended'); 
    imshow(out);
end

