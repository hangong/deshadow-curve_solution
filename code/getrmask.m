function seg_o = getrmask(im,simsk)
%GTERMASK Get the rough shadow mask
%
% Copyright Han Gong 2014

global deb
imsz = size(im); imhw = imsz(1:2);
[Lb,Ln] = bwlabel(simsk,4);

fim = im;
for ch = 1:3 % filter image
    fim(:,:,ch) = medfilt2(fim(:,:,ch),[3,3],'symmetric');
end

%lim = log(max(fim,eps));
lim = fim;

FeatSpace = zeros(imhw(1)*imhw(2),3);
for i = 1:3
    tmp = lim(:,:,i);
    FeatSpace(:,i) = tmp(:);
end

lidx = []; sidx = [];
for l = 1:Ln
   li = find(Lb == l); % index of current blob
   [fx,fy] = ind2sub(imhw,li); % get coordinates
   [~,rg] = pca([fx,fy]); % use PCA to prepare geo-feature
   nrg = mat2gray(rg);
   done = false;
   while ~done
    [IDX,DC] = kmeans([FeatSpace(li,:),nrg],2,...
        'emptyaction','drop'); % run kmeans clustering
    if ~sum(isnan(DC)), done = true; end
   end
   [~,ll] = max(mean(DC(:,1:3),2));
   lidx = [lidx;li(IDX==ll)]; sidx = [sidx;li(IDX~=ll)]; % label pixels
end

% umbra feature selection
ShaNum = size(sidx,1); LitNum = size(lidx,1); SamNum = ShaNum + LitNum;
FeatClass = zeros(SamNum,1);
FeatClass(1:ShaNum) = 1; % mark shadow ones
TrainFeats = zeros(SamNum,3);
for i = 1:3
    tmp = lim(:,:,i);
    TrainFeats(1:ShaNum,i) = tmp(sidx);
    TrainFeats(ShaNum+1:end,i) = tmp(lidx);
end

% umbra learning and rough mask prediction
model = ClassificationKNN.fit(TrainFeats,FeatClass,'NumNeighbors',3);

[~,slb] = predict(model,FeatSpace);
lbimg = reshape(slb(:,1),imhw);
gsH = fspecial('gaussian',5,3);
smatt = imfilter(lbimg,gsH,'replicate');
p_th = 0.5; % threshold of KNN poster-probablity
oim = ones(imhw); oim(smatt>p_th)= 0;

% get the largest component
if ~isempty(find(~oim, 1))
    seg_o = ~imfillhole(~imfillhole(oim, 100), 200);
else
    seg_o = [];
end

%% plot debug info
if deb
    figure('Name','Sampling Lines And Shadow Boundary');
    simg = im; % plot user input
    imel = imhw(1)*imhw(2);
    simg(lidx) = 1; simg(sidx+2*imel) = 1;
    imshow(simg); axis image; hold on;
end

end
