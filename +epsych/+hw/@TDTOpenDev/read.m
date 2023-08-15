function v = read(obj,parameter) % epsych.hw.TDTOpenDev
% v = read(obj,parameter)

    
if isa(parameter,'epsych.par.Parameter')

    switch parameter.DataClass
        case 'scalar'
            v = obj.handle.GetTagVal(parameter.Name);

        case 'buffer'
            s = obj.handle.GetTagSize(parameter.Name);
            v = obj.handle.ReadTagV(parameter.Name,0,s);

        case 'table'
            s = obj.handle.GetTagSize(parameter.Name);
            v = obj.handle.ReadTagVEX(parameter.Name,0,s,'F32',value);
    end
        
elseif isa(parameter,'epsych.par.Group')
    v = arrayfun(@read,parameter.Parameters);

else
    p = parameter.Parameter(parameter);
    v = read(p);
end