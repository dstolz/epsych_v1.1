function e = write(obj,src,event)  % epsych.hw.TDTActiveX
% e = write(obj,parameter,value) % manually called
% e = write(obj,src,event) % called by a Parameter property listener

if nargin < 3, event = []; end

if isa(event,'event.PropertyEvent') % called by a Parameter property listener
    parameter = event.AffectedObject;
    value = [];
else
    parameter = src;
    value = event;
end



if isempty(value)
    value = parameter.Value; % ???
end
    

if isa(parameter,'epsych.par.Parameter')

    switch parameter.DataClass
        case 'scalar'
            e = obj.handle.SetTagVal(parameter.Name,value);

        case 'buffer'
            value = value(:)';
            e = obj.handle.WriteTagV(parameter.Name,value);

        case 'table'
            e = obj.handle.WriteTagVEX(parameter.Name,0,'F32',value);
    end

elseif isa(parameter,'epsych.par.Group')
    e = arrayfun(@obj.write,parameter.Parameters);

else
    p = parameter.Parameter(parameter); % ??
    e = obj.write(p,value);
end