function [nt,bl] = spsig(bl,ot,dimg)
%SPSIG samples and selects valid signals
%
% Copyright Han Gong 2014
global deb;

imsz = size(dimg); imhw = imsz(1:2);
len = size(bl.s,2); % length of selected boundary points
tt = ot(ot~=-1); % a copy of original types

%% filter signals using constraint of length
svec = bl.s-bl.e; % vector of sampling line
slen = arrayfun(@(x) norm(svec(:,x)), 1:len); % sampling line lengthes
l_l = 3; h_l = mean(slen)+3*std(slen);
tt(slen<=l_l|slen>=h_l) = -2; % reject sample with invalid length
% get sample id with valid length
lsid = find(~tt);
llen = length(lsid);

bl.v = cell(len,1); bl.cx = cell(len,1); bl.cy = cell(len,1);
%% sample raw signal
for i = 1:llen
    id = lsid(i);
    % sampling line pixel coordinates
    xi = sat([bl.s(1,id),bl.e(1,id)],1,imhw(2));
    yi = sat([bl.s(2,id),bl.e(2,id)],1,imhw(1));
    % sample signals
    [bl.cx{i},bl.cy{i},bl.v{i}] = improfile(dimg,xi,yi);
    bl.v{i} = permute(bl.v{i},[1,3,2]);
end

%% filter signals using constraint of illumination change
% reject invalid samples due to illumination change dismatch
clen = 3; % rough scale length
cs = zeros(clen,3,llen); % re-scaled intensity
for i = 1:llen % re-scale intensity for rough scaling
    cs(:,:,i) = resize(bl.v{i},[clen,3]);
end
lcs = log(max(cs,eps)); % log-domain intensity
dls = diff(lcs); % RGB scales
fs = reshape(dls,[],llen); % feature vector
cm = dbscan(fs',3,0.2); % classify the illumination changes
[~,hc] = max(histc(cm,1:max(cm))); % find the majority group
if ~isempty(hc)
    mm = imfillhole(cm==hc,5); % prevent noise
    tt(lsid(~mm)) = -3; % discard minorities
end
csid = find(~tt);

nt = ot; nt(ot~=-1) = tt; % update boundary point types
% filter bad sampling lines
[vid,vidk] = intersect(lsid,csid);

if deb
    % plot sampling lines
    for i = vid'
        sxi = [bl.s(1,i),bl.e(1,i)]; syi = [bl.s(2,i),bl.e(2,i)];
        plot(sxi,syi,'b-');
    end
    isid = setxor(1:len,vid'); % get invalid sample id
    pi = NaN(2,1); tc = {'c-','r-'};
    txt = {'invalid length','invalid quality'};
    for i = isid
        sxi = [bl.s(1,i),bl.e(1,i)]; syi = [bl.s(2,i),bl.e(2,i)];
        tid = -tt(i)-1;
        pi(tid) = plot(sxi,syi,tc{tid});
    end
    % plot inner and outer boundaries
    li = arrayfun(@(x) ~isnan(x),pi);
    if ~isempty(li), legend(pi(li),txt{li}); end
    hold off;
end

bl.s = bl.s(:,vid); bl.e = bl.e(:,vid);
bl.cx = bl.cx(vidk); bl.cy = bl.cy(vidk); bl.v = bl.v(vidk);
bl.l = arrayfun(@(x) size(bl.v{x},1), find(vidk)); % line lengthes

end
