function startFcn(obj) % epsych.expt.Runtime

% Make sure we have the DataDirectory available
if ~isfolder(obj.Config.DataDirectory)
    obj.Log.write('Critical','Creating Data directory: %s',obj.Config.DataDirectory);
    mkdir(obj.Config.DataDirectory);
end


% Setup each subject
for i = 1:numel(obj.Subject)
    S = obj.Subject(i);
    
    if S.Active == false
        obj.Log.write('Critical','Skipping Subject "%s" [%d] - subject is inactive',S.Name,S.ID);
        continue
    end
    
    if isempty(S.BitmaskFile)
        obj.Log.write('Important','No Bitmask file is specified for Subject "%s" [%d]',S.Name,S.ID);
    else
        obj.Log.write('Verbose','Initializing Subject "%s" [%d] Bitmask data ("%s")',S.Name,S.ID,S.BitmaskFile);
        S.Data = epsych.Data(S.BitmaskFile);
    end
end





% Launch user gui (if specified)
feval(obj.Config.UserInterface,obj);



% Setup hardware
for i = 1:numel(obj.Hardware)
    H = obj.Hardware{i};
    
    for j = 1:length(H.digLines)
        if ~H.digLines(j).isOutput, continue; end
        obj.Log.write('Debug','Adding listener for digLine %d on "%s"',j,H.Alias)
        addlistener(H.digLines(j),'State','PostSet',@H.set_digital_line);
    end
    
    
    obj.Log.write('Verbose','Run Hardware: %s',H.Name);
    e = H.start(obj);
    
    if e
        obj.Log.write('Error',H.ErrorME);
        obj.State = epsych.enState.Error;
        return
    end
end
















