function e = write(obj,parameter,value)  % epsych.hw.TDTActiveX

useParameterValue = nargin < 3 | isempty(value);

if useParameterValue
    value = epsych.param.Value;
end
    
mind = epsych.param.ModuleID == obj.ModuleID;


if isa(parameter,'epsych.param.Parameter')

    switch epsych.param.DataClass
        case 'scalar'
            e = obj.handle(mind).SetTagVal(epsych.param.Name,value);

        case 'buffer'
            value = value(:)';
            e = obj.handle(mind).WriteTagV(epsych.param.Name,value);

        case 'table'
            e = obj.handle(mind).WriteTagVEX(epsych.param.Name,0,'F32',value);
    end

elseif isa(parameter,'epsych.param.Group')
    e = arrayfun(@write,epsych.param.Parameters);

else
    p = epsych.param.Parameter(parameter);
    e = write(p,value);
end