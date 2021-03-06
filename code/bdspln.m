function bl = bdspln(ffu,smsk,bd,gsc)
%BDSPLN provides the two ends of each sampling line
%
% Copyright Han Gong 2014

vi = ~bd.t;
bdp = bd.p(:,vi); bdn = bd.n(:,vi);

llen = size(bdp,2); % length of selected boundary points
imhw = size(ffu); % size of image
bl.s = zeros(2,llen); bl.e = zeros(2,llen); % shadow boundary points
tt = zeros(llen,1);

% compute illumination gradient field
[fx,fy] = gradient(ffu);

% get endpoints
for i = 1:llen
    % get current parameters
    pt = bdp(:,i); % bounary point
    ptinc = bdn(:,i); % advance vector using boundary normal vector
    gvec = [fx(pt(2),pt(1));fy(pt(2),pt(1))];
    % get starting end
    cpt1 = round(pt); cpt2 = round(pt); % current ends
    gmlen = get2Dprolen(gvec,ptinc)/gsc; % minimum gradient strength
    t1 = false;
    while ~tt(i)
        rcpt1 = round(cpt1); rcpt2 = round(cpt2);
        if reachbd(rcpt1,imhw) || reachbd(rcpt2,imhw) || gmlen<=0
            tt(i) = -2; % boundary check
        else
            if t1 && (~smsk(rcpt1(2),rcpt1(1)) || smsk(rcpt2(2),rcpt2(1)))
                tt(i) = -2; % mask check
            end
            cgvec1 = [fx(rcpt1(2),rcpt1(1)),fy(rcpt1(2),rcpt1(1))];
            cgvec2 = [fx(rcpt2(2),rcpt2(1)),fy(rcpt2(2),rcpt2(1))];
            ig1 = get2Dprolen(cgvec1, ptinc);
            ig2 = get2Dprolen(cgvec2, ptinc);
            if (ig1+ig2)/2 < gmlen  % gradient check
                break;
            else
                cpt1 = cpt1 - ptinc; cpt2 = cpt2 + ptinc; t1 = true;
            end
        end
    end
    bl.s(:,i) = cpt1; bl.e(:,i) = cpt2;
end
%nt = bd.t; nt(vi) = tt;

function res = reachbd(pt,sz)
    % test whether a point is at image boarder
    res = pt(1)<1 || pt(2)<1 || pt(1) > sz(2) || pt(2) > sz(1);
end

end

