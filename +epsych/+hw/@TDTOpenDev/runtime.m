function e = runtime(obj,Runtime) % TDTOpenDev
e = false;
try
    obj.read_digital_lines;
    
    for i = 1:length(obj.Parameters)
        % ????????? update Data??? or Value???
        obj.Parameters(i).Data = obj.read(obj.Parameters(i));
    end
    
catch me
    obj.ErrorME = me;
    e = true;
end


