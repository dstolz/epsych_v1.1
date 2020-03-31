function v = read(obj,parameter) % epsych.hw.TDTActiveX


    
if isa(parameter,'epsych.param.Parameter')

    mind = epsych.param.ModuleID == obj.ModuleID;

    switch epsych.param.DataClass
        case 'scalar'
            v = obj.handle(mind).GetTagVal(epsych.param.Name);

        case 'buffer'
            s = obj.handle(mind).GetTagSize(epsych.param.Name);
            v = obj.handle(mind).ReadTagV(epsych.param.Name,0,s);

        case 'table'
            s = obj.handle(mind).GetTagSize(epsych.param.Name);
            v = obj.handle(mind).ReadTagVEX(epsych.param.Name,0,s,'F32',value);
    end
        
elseif isa(parameter,'epsych.param.Group')
    v = arrayfun(@read,epsych.param.Parameters);

else
    p = epsych.param.Parameter(parameter);
    v = read(p);
end