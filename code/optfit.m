function vo = optfit(tsig)
% v = optfit(sig) This function fits signal to a piece-wise cubic curve
%
% Copyright Han Gong 02/04/2014

    function f = objfun(v) % object function
        y = fm(wx,v); % evaluate
        f = sumsqr(tsig-y); % get error
    end

    slen = size(tsig,1); % get length of signal
    wx = linspace(0,1,slen); % x coordinates
    smin = min(tsig); smax = max(tsig); % get maxmin of signal
    v0 = [smax-smin,smin,1,0]'; % initial guess of fit
    lb = [(smax-smin)/2,0,0,0,0.25,-0.5]';
    ub = [ones(1,3),(smax+smin)/2,slen,0.5]'; % para limit
    options = optimset('Algorithm','sqp','Display','off');
    A = [1,0,0,1,0,0,0,0;...
         0,1,0,0,1,0,0,0;...
         0,0,1,0,0,1,0,0];
    b = [1;1;1];
    v = fmincon(@objfun,v0,A,b,[],[],lb,ub,[],options);
    vo = zeros(1,5);
    vo(1:3) = v(4:6)./(v(1:3)+v(4:6));
    vo(4:5) = v(7:8);
%debug only
%{
    figure;
    plot(wx,tsig(:,1));
    hold on;
    plot(wx,y(:,1),'r');
    hold off;
%}
end