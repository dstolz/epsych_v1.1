function e = trigger(obj,parameter,invert) % hardware.TDTActiveX
% e = trigger(obj,parameter,[invert])

% TODO: need to figure out idx


if nargin < 3, invert = 0; end

if isa(parameter,'parameter.Parameter')
    if startsWith(parameter.Name,'SoftTrg~')
        e = obj.handle(idx).SoftTrg(str2double(parameter.Name(end)));
    else
        e1 = obj.handle(idx).SetTagVal(parameter.Name,~invert);
        e2 = obj.handle(idx).SetTagVal(parameter.Name,invert);
        e = e1 & e2;
    end

elseif isa(parameter,'parameter.Group')
    e = arrayfun(@trigger,parameter.Parameters,repmat(invert,size(parameter.Parameters)));

else
    if startsWith(parameter.Name,'SoftTrg~')
        e = obj.handle(idx).SoftTrg(str2double(parameter.Name(end));
    else
        e1 = obj.handle(idx).SetTagVal(parameter,~invert);
        e2 = obj.handle(idx).SetTagVal(parameter,invert);
        e = e1 & e2;
    end
end