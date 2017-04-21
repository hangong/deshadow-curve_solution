function gt_adj()
addpath('../code');

%% get folders for adjustment
gpath = 'gt_in_pool/'; % ground truth path
gfpath = 'gt_fix_pool/'; % fixed files
%% obtain image files
fl = sort_nat(getAllFiles(gpath));
img_name = cellfun(@(x) sscanf(x, '%[^.]'),fl,'UniformOutput',false);
img_ext = cellfun(@(x) sscanf(x, '%*[^.]%*[.]%s'),fl,'UniformOutput',false);
hd = cellfun(@(x) x(1:end-2),img_name,'UniformOutput',false); % prefix
ed = cellfun(@(x) x(end-1:end),img_name,'UniformOutput',false); % postfix
sidx = find(~cellfun(@(x) strcmp(x,'_n'),ed)); % index of shadow image
slen = length(sidx); % number of testcases
if ~exist(gfpath,'dir'), mkdir(gfpath); end
for s = 1:slen
    i = sidx(s);
    gt = im2double(imread([gpath,hd{i},'_n.',img_ext{i}]));
    simg = im2double(imread([gpath,img_name{i},'.',img_ext{i}]));
    % adjust GT
    rim = simg./max(gt,1/256); % ratio image
    arim = mean(rim,3); % average ratio
    imsz = size(gt); imel = imsz(1)*imsz(2);
    ms = mean2(arim);
    if ms>1 % GT adjustment
        done = false;
        while ~done
            [IDX,DC] = kmeans(min(reshape(rim,[],3),2),2,...
             'emptyaction','drop'); % run kmeans clustering
            if ~sum(isnan(DC)), done = true; end
        end
        [~,ll] = max(mean(DC,2));
        id = find(IDX==ll);
        asc = zeros(3,1); % compute scales to apply
        ngt = zeros(imsz);
        for ch = 1:3 % adjust gt
            asc(ch) = mean(rim(id+imel*(ch-1)));
            ngt(:,:,ch) = gt(:,:,ch)*asc(ch);
        end
        imwrite(ngt,[gfpath,hd{i},'_n.',img_ext{i}]);
    end    
end

rmpath('../code');
end
