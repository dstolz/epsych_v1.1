function e = trigger(obj,parameter,invert) % epsych.hw.TDTOpenDev
% e = trigger(obj,parameter,[invert])

% TODO: need to figure out idx


if nargin < 3, invert = 0; end

if isa(parameter,'epsych.par.Parameter')
    if startsWith(epsych.par.Name,'SoftTrg~')
        e = obj.handle(idx).SoftTrg(str2double(epsych.par.Name(end)));
    else
        e1 = obj.handle(idx).SetTagVal(epsych.par.Name,~invert);
        e2 = obj.handle(idx).SetTagVal(epsych.par.Name,invert);
        e = e1 & e2;
    end

elseif isa(parameter,'epsych.par.Group')
    e = arrayfun(@trigger,epsych.par.Parameters,repmat(invert,size(epsych.par.Parameters)));

else
    if startsWith(epsych.par.Name,'SoftTrg~')
        e = obj.handle(idx).SoftTrg(str2double(epsych.par.Name(end)));
    else
        e1 = obj.handle(idx).SetTagVal(parameter,~invert);
        e2 = obj.handle(idx).SetTagVal(parameter,invert);
        e = e1 & e2;
    end
end