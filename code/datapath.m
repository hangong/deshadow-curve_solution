function paths = datapath(op)
%DATAPATH adds or remove dirs of images
%
% Copyright Han Gong 2014

paths = {
'guo/original'; % path of Guo's dataset
%'demo'; % path of demo test
%'data/original' % path of our dataset
%'demo';
};

if op
    cellfun(@(x) addpath(x),paths);
else
    cellfun(@(x) rmpath(x),paths);
end

end
