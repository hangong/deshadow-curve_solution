function [bl,bd] = fitsig(bl,bd)
%ALNSIG aligns the signals and fit sample
%
% Copyright Han Gong 2014
global deb

alen = max(bl.l); % average bl.vnal length
vlen = length(bl.l); % number of valid samples
rsig = zeros(alen,3,vlen); % re-scaled intensity

%% re-scale intensity
for i = 1:vlen, rsig(:,:,i) = resize(bl.v{i},[alen,3]); end
blen = numel(bl.l); bl.sc = cell(blen,1); bl.p = cell(blen,1);

%% fit sampling using piece-wise cubic curve
blm = bd.m(~bd.t);
ri = linspace(0,1,alen); % re-scaled sample sites
osig = zeros(alen,3,vlen); % original sample
ssig = zeros(alen,3,vlen); % artefact-free sample
wsig = zeros(alen,3,vlen); % relighed sample
for m = unique(blm)'
    mi = find(blm == m); % find the index of a boundary
    ml = numel(mi); % length of index
    mv = zeros(length(mi),5); % parameters
    msig = rsig(:,:,mi); % signal of current contour
    for ch = 1:3 % remove texture noise in samples
        %msig(:,ch,:) = medfilt2(squeeze(msig(:,ch,:)),[3,9],'symmetric');
        msig(:,ch,:) = bFilter(squeeze(msig(:,ch,:)));
    end
    fsig = msig; % store initally filtered sample.
    for i = 1:ml, mv(i,:) = optfit(msig(:,:,i)); end % fit sample
    cm = dbscan(mv(:,1:3),3,0.01); % detect outlier scales
    [~,hc] = max(histc(cm,1:max(cm)));
    if isempty(hc), ig = false(size(cm)); else ig = cm~=hc; end
    mv(ig,:) = NaN; % mark outliers
    for ch = 1:5, mv(:,ch) = smoothn(mv(:,ch)); end % smooth the scales
    ss = 0.5-1./mv(:,4)/nanmean(1./mv(:,4))/2; % scale shift
    cs = mv(:,5);
    for i = 1:ml % pre-processing
        tsc = fm(linspace(0,1,alen),[1-mv(i,1:3),mv(i,:)]); % evaluate
        bl.p{mi(i)} = mv(i,:);
        trs = msig(:,:,i)./tsc; % apply relighting
        si = linspace(ss(i),1-ss(i),alen)+cs(i); % re-algined sites
        for ch = 1:3 % aligned signals
            trs(:,ch) = interp1(ri,trs(:,ch),si,'nearest','extrap');
        end
        msig(:,:,i) = trs;
    end
    osig(:,:,mi) = msig; % store original sample
    msig(:,:,~ig) = filtres(msig(:,:,~ig)); % remove mac band artefact
    ssig(:,:,mi) = msig; % store the aligned artefact free stuff
    trs = zeros(alen,3,ml);
    for i = 1:ml % compute scales
        si = linspace(ss(i),1-ss(i),alen)+cs(i); % re-algined sites
        for ch = 1:3 % revert shifts
            trs(:,ch,i) = interp1(si,msig(:,ch,i),ri,'nearest','extrap');
        end
        tv = resize(trs(:,:,i),[bl.l(mi(i)),3]); % re-scale the sample
        bl.sc{mi(i)} = bl.v{mi(i)}./tv;
    end
    wsig(:,:,mi) = rsig(:,:,mi)./(fsig./trs);
end

%% rectify boundary points and sampling line
bdv = bl.e-bl.s; % original sampling vector (2xN)
vw = arrayfun(@(x) norm(bdv(:,x)), 1:blen);
bd.w = zeros(1,length(bd.t)); bd.w(~bd.t) = vw;
wp = permute(wsig,[1,3,2]); % wrap

if deb
    % re-aligned RGB wrap
    sc = zeros(size(rsig));
    for i = 1:blen, sc(:,:,i) = resize(bl.sc{i},[alen,3]); end
    aview = permute(rsig,[1,3,2]);
    view = permute(sc,[1,3,2]);
    iview = permute(osig,[1,3,2]);
    sview = permute(ssig,[1,3,2]);
    % plot stuff
    figure('Name','Penumbra Wrap');
    subplot(5,1,1);imshow(aview);title('wrapped penumbra');
    subplot(5,1,2);imshow(view);title('wrapped penumbra scale');
    subplot(5,1,3);imshow(iview);title('initial removal');
    subplot(5,1,4);imshow(sview);title('smoothed removal');
    subplot(5,1,5);imshow(wp);title('relighted wrap');
    axis off; axis image;
end

end
