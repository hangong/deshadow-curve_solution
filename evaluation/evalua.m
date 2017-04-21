
%% get folders for evaluation
base = 'eval/';
dirData = dir(base);dirIndex = [dirData.isdir];
subDirs = {dirData(dirIndex).name};
vIdx = ~ismember(subDirs,{'.','..'}); vDirs = subDirs(vIdx);
dnum = numel(vDirs); % number of dirs

gpath = 'guo/img/'; % ground truth path
mk = []; load mk.mat; % load attribute data
%% obtain image files
fl = sort_nat(getAllFiles(gpath));
img_name = cellfun(@(x) sscanf(x, '%[^.]'),fl,'UniformOutput',false);
img_ext = cellfun(@(x) sscanf(x, '%*[^.]%*[.]%s'),fl,'UniformOutput',false);
hd = cellfun(@(x) x(1:end-2),img_name,'UniformOutput',false); % prefix
ed = cellfun(@(x) x(end-1:end),img_name,'UniformOutput',false); % postfix
sidx = find(~cellfun(@(x) strcmp(x,'_n'),ed)); % index of shadow image
slen = length(sidx); % number of testcases
%% compute scores for all images
sc = zeros(slen,2,dnum); % scores [case,statis,method]
for s = 1:slen
    i = sidx(s);
    gt = im2double(imread([gpath,hd{i},'_n.',img_ext{i}]));
    simg = im2double(imread([gpath,img_name{i},'.',img_ext{i}]));
    for j = 1:dnum
        rimg = im2double(imread([base,vDirs{j},'/',img_name{i},'.tif']));
        sc(s,:,j) = getsc(rimg,gt,simg);
    end
end
% save scores
save([base,'sc'],'sc');

%% compute scores statistics for attributes
fdn = fieldnames(mk.cat); % attributes
nc = length(fdn); % number of attributes
csc = zeros(2,dnum,nc,2,2); % scores [type,method,cat,statis,det]

umsk = ~mk.mask; % excluded detection failure
for i = 1:nc
    cmsk = mk.cat.(fdn{i}); % mask of current attribute
    umsk = cmsk & ~mk.mask; % excluded detection failure
    csc(:,:,i,1,1) = permute(mean(sc(cmsk,:,:),1),[2,3,1]); % mean
    csc(:,:,i,2,1) = permute(std(sc(cmsk,:,:),1),[2,3,1]); % std
    csc(:,:,i,1,2) = permute(mean(sc(umsk,:,:),1),[2,3,1]); % ex mean
    csc(:,:,i,2,2) = permute(std(sc(umsk,:,:),1),[2,3,1]); % ex std
end

%% display result
for i = 1:dnum % method
    fprintf('%s\n',vDirs{i});
    for c = 1:nc
        % print other attribute
        fprintf('%s - %s\n',vDirs{i},fdn{c});
        for j = 1:2 % detection
            for sct = 1:2 % score type (all,shadow)
                fprintf('%.2f (%.2f)\t',csc(sct,i,c,1,j),csc(sct,i,c,2,j));
            end
        end; fprintf('\n');
    end; fprintf('\n');
end

% save statistics
save([base,'res'],'vDirs','csc');

