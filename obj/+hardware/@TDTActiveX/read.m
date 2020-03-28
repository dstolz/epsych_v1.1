function v = read(obj,parameter) % hardware.TDTActiveX


    
if isa(parameter,'parameter.Parameter')

    mind = parameter.ModuleID == obj.ModuleID;

    switch parameter.DataClass
        case 'scalar'
            v = obj.handle(mind).GetTagVal(parameter.Name);

        case 'buffer'
            s = obj.handle(mind).GetTagSize(parameter.Name);
            v = obj.handle(mind).ReadTagV(parameter.Name,0,s);

        case 'table'
            s = obj.handle(mind).GetTagSize(parameter.Name);
            v = obj.handle(mind).ReadTagVEX(parameter.Name,0,s,'F32',value);
    end
        
elseif isa(parameter,'parameter.Group')
    v = arrayfun(@read,parameter.Parameters);

else
    p = parameter.Parameter(parameter);
    v = read(p);
end