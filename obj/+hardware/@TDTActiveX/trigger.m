function e = trigger(obj,parameter,invert) % hardware.TDTActiveX
% e = trigger(obj,parameter,[invert])

if nargin < 3, invert = 0; end

if startsWith(parameter.Name,'SoftTrg~')
    e = obj.handle(idx).SoftTrg(str2double(parameter.Name(end)));
else
    e1 = obj.handle(idx).SetTagVal(parameter.Name,~invert);
    e2 = obj.handle(idx).SetTagVal(parameter.Name,invert);
    e = e1 & e2;
end
