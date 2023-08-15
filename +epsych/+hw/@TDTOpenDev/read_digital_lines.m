function read_digital_lines(obj)

D = obj.DigIO.digLines;
for i = 1:length(D)
    D(i).State = obj.handle.GetTagVal(D(i).Label);
end
