function e = runtime(obj,Runtime) % TDTActiveX
e = false;
try
    obj.read_digital_lines;
    
catch me
    obj.ErrorME = me;
    e = true;
end


