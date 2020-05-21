function timerFcn(obj) % epsych.expt.Runtime

if mod(obj.Timer.TasksExecuted,100) == 0
    fprintf('AvgPeriod = %.3f ms ; InstantPeriod = %.3f ms\n', ...
        1000*obj.Timer.AveragePeriod,1000*obj.Timer.InstantPeriod)
end