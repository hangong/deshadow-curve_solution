function sc = getsc(rimg,gt,simg)
    % function to caculate scores
    sc = zeros(1,2);
    % get images
    dat = rimg(:);
    ref = gt(:);
    das = simg(:);
    % compute scale
    scale = das./ref;

    si = find(scale<1);

    sf = (das-ref).^2;
    tf = (dat-ref).^2;

    % RMSE all
    b1 = sqrt(sum( sf / numel(dat)));
    a1 = sqrt(sum( tf / numel(dat)));
    sc(1) = a1/b1;

    % RMSE shadow
    b2 = sqrt(sum( (sf(si)).^2) / numel(si));
    a2 = sqrt(sum( (tf(si)).^2) / numel(si));
    sc(2) = a2/b2;
    
end