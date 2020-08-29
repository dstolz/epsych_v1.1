function startFcn(obj) % epsych.expt.Runtime
    global LOG

    % Make sure we have the DataDirectory available
    if ~isfolder(obj.Config.DataDirectory)
        LOG.write('Critical','Creating Data directory: %s',obj.Config.DataDirectory);
        mkdir(obj.Config.DataDirectory);
    end


    % Setup each subject
    for i = 1:numel(obj.Subject)
        S = obj.Subject(i);
        
        if S.Active == false
            LOG.write('Critical','Skipping Subject "%s" [%d] - subject is inactive',S.Name,S.ID);
            continue
        end

        if isempty(S.BitmaskFile)
            LOG.write('Important','No Bitmask file is specified for Subject "%s" [%d]',S.Name,S.ID);
        else
            LOG.write('Verbose','Initializing Subject "%s" [%d] Bitmask data ("%s")',S.Name,S.ID,S.BitmaskFile);
            S.Data = epsych.Data(S.BitmaskFile);
        end
    end


    for i = 1:numel(obj.Hardware)
        H = obj.Hardware(i);
        LOG.write('Verbose','Run Hardware: %s',H.Name);
        e = H.run;

        if e
            LOG.write('Error',H.ErrorME);
            obj.State = epsych.enState.Error;
            return
        end
    end