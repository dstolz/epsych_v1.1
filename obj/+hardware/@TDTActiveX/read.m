function v = read(obj,parameter) % hardware.TDTActiveX

mind = parameter.ModuleID == obj.ModuleID;

switch parameter.DataClass
    case 'scalar'
        v = obj.handle(mind).GetTagVal(parameter.Name);

    case 'buffer'
        s = obj.handle(mind).GetTagSize(parameter.Name);
        v = obj.handle(mind).ReadTagV(parameter.Name,0,s);

    case 'table'
        s = obj.handle(mind).GetTagSize(parameter.Name);
        v = obj.handle(mind).WriteTagVEX(parameter.Name,0,s,'F32',value);
end
    