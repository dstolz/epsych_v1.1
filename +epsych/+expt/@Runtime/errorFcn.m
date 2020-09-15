function errorFcn(obj) % epsych.expt.Runtime


for i = 1:length(obj.Hardware)
    obj.Log.write('Debug','Calling Hardware "%s" error function',obj.Hardware{i}.Alias)
    obj.Hardware{i}.error(obj);
end
