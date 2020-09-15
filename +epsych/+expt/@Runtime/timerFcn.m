function timerFcn(obj) % epsych.expt.Runtime

doTheDebug = obj.Log.Verbosity >= epsych.log.Verbosity.Debug;

if doTheDebug
    if mod(obj.Timer.TasksExecuted,100) == 0
        obj.Log.write('Debug','AvgPeriod = %.3f ms ; InstantPeriod = %.3f ms', ...
            1000*obj.Timer.AveragePeriod,1000*obj.Timer.InstantPeriod)
    end
end

for i = 1:length(obj.Hardware)
    if obj.Hardware{i}.runtime(obj)
        error('epsych:expt:Runtime:timerFcn:RuntimeError', ...
            'Error returned from %s [%s] runtime function',obj.Hardware{i}.Name,obj.Hardware{i}.Type);
    end
end

