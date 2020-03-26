function e = write(obj,parameter,value)  % hardware.TDTActiveX

useParameterValue = nargin < 3 | isempty(value);

if useParameterValue
    value = parameter.Value;
end
    
mind = parameter.ModuleID == obj.ModuleID;

switch parameter.DataClass
    case 'scalar'
        e = obj.handle(mind).SetTagVal(parameter.Name,value);

    case 'buffer'
        value = value(:)';
        e = obj.handle(mind).WriteTagV(parameter.Name,value);

    case 'table'
        e = obj.handle(mind).WriteTagVEX(parameter.Name,0,'F32',value);
end
