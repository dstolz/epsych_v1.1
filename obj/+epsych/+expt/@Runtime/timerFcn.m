function timerFcn(obj) % epsych.expt.Runtime

global RUNTIME

doTheDebug = RUNTIME.Log.Verbosity == epsych.log.Verbosity.Debug;

if doTheDebug
    if mod(obj.Timer.TasksExecuted,100) == 0
        RUNTIME.Log.write('Debug','AvgPeriod = %.3f ms ; InstantPeriod = %.3f ms', ...
            1000*obj.Timer.AveragePeriod,1000*obj.Timer.InstantPeriod)
    end
end


e = obj.runtime;

if e
    error('epsych:expt:Runtime:timerFcn:RuntimeError', ...
        'Error returned from %s [%s] runtime function',obj.Name,obj.Type);
end