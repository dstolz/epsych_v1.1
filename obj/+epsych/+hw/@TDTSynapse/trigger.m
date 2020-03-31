function e = trigger(obj,parameter,invert) % epsych.hw.TDTActiveX
% e = trigger(obj,parameter,[invert])

% TODO: need to figure out idx


if nargin < 3, invert = 0; end

if isa(parameter,'epsych.param.Parameter')
    if startsWith(epsych.param.Name,'SoftTrg~')
        e = obj.handle(idx).SoftTrg(str2double(epsych.param.Name(end)));
    else
        e1 = obj.handle(idx).SetTagVal(epsych.param.Name,~invert);
        e2 = obj.handle(idx).SetTagVal(epsych.param.Name,invert);
        e = e1 & e2;
    end

elseif isa(parameter,'epsych.param.Group')
    e = arrayfun(@trigger,epsych.param.Parameters,repmat(invert,size(epsych.param.Parameters)));

else
    if startsWith(epsych.param.Name,'SoftTrg~')
        e = obj.handle(idx).SoftTrg(str2double(epsych.param.Name(end));
    else
        e1 = obj.handle(idx).SetTagVal(parameter,~invert);
        e2 = obj.handle(idx).SetTagVal(parameter,invert);
        e = e1 & e2;
    end
end