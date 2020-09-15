function stopFcn(obj) % epsych.expt.Runtime



% Setup hardware
for i = 1:numel(obj.Hardware)
    H = obj.Hardware{i};
    obj.Log.write('Verbose','Stopping Hardware: %s',H.Name);
    e = H.stop;
    
    if e
        obj.Log.write('Error',H.ErrorME);
        obj.State = epsych.enState.Error;
        return
    end
end


% TODO: Save Subject data