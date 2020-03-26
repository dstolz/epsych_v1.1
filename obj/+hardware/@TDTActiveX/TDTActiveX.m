classdef TDTActiveX < hardware.Hardware

    properties (Constant)
        Name         = 'TDTActiveX';
        Type         = 'COM.RPco_x';
        Description  = 'Standalone TDT ActiveX controls';
    end

    
    properties (SetAccess = private)
        handle       % handle to ActiveX or SDK or whatever
    end
    
    properties
        State          (1,1) epsych.State = epsych.State.Prep;

        Parameters

        ConnectionType (1,:) char {mustBeMember(ConnectionType,{'GB','USB'})} = 'GB';
        ModuleAlias    (1,:) char
        Module         (1,:) char {mustBeMember(Module,{'Undefined','RP2','RA16','RL2','RV8','RX5','RX6','RX7','RX8','RZ2','RZ5','RZ6','RM1','RM2'})} = 'Undefined';
        ModuleID       (1,1) double {mustBePositive,mustBeInteger} = 1;
        RPvdsFile      (1,:) char
        Fs             (1,1) double {mustBePositive,mustBeFinite} = 24414.0625; % Hz
    end


    properties (Dependent)
        Status
        FsInt
    end

    properties (Access = private)
        emptyFig
    end

    methods
        write(obj,parameter,value);
        v = read(obj,parameter);
        e = trigger(obj,parameter);

        function obj = TDTActiveX
            % call superclass constructor
            obj = obj@hardware.Hardware;
        end

        function set.State(obj,newState)
            switch newState
                case 'Prep'
                    obj.prepare;

                case {'Run','Preview'}
                    obj.run;
                    
                case 'Pause'
                    % nothing to do here
                    
                case 'Halt'
                    obj.stop;

            end
            obj.State = newState;
        end

        function prepare(obj)
            % prepare(obj)
            %
            % where mod is a valid module type: 'RZ5','RX6','RP2', etc..
            %   modid is the module id.  default is 1.
            %   ct is a connection type:  'GB' or 'USB'
            %   rpfile is the full path to an RPvds file.
            %
            % returns RP which is the handle to the RPco.x control.  Also returns
            % status which is a bitmask of the module status.  Use with bitget function
            %   Bit# 0 = Connected
            %   Bit# 1 = Circuit loaded
            %   Bit# 2 = Circuit running
            %   Bit# 3 = RA16BA Battery
            % (see page 43 of ActiveX reference manual for more status values).
            %
            % Optionally specify the sampling frequency (Fs).  See "LoadCOFsf" in the
            % TDT ActiveX manual for more info.
            %   Fs = 0  for 6 kHz
            %   Fs = 1  for 12 kHz
            %   Fs = 2  for 25 kHz
            %   Fs = 3  for 50 kHz
            %   Fs = 4  for 100 kHz
            %   Fs = 5  for 200 kHz
            %   Fs = 6  for 400 kHz
            %   Fs > 50 for arbitrary sampling rates (RX6)

            if ~exist(obj.RPvdsFile,'file')
                errordlg(sprintf('File does not exist: "%s"',obj.RPvdsFile), ...
                    'File Does Not Exist', ...
                    'modal');
                return
            end
            
            if obj.Status == hardware.Status.Running
                fprintf('RPco.X already connected, loaded, and running.\n')
                return
            end

            h = findobj('Name','RPfig');
            if isempty(h)
                h = figure('Visible','off','Name','RPfig');
            end

            for i = 1:length(obj.Module)
                module = obj.Module{i};
                if strcmp(module,'Undefined'), continue; end

                modid  = obj.ModuleID(i);
                rpfile = obj.RPvdsFile{i};
            
                obj.handle(i) = actxcontrol('RPco.x','parent',h);

                if ~eval(sprintf('obj.handle.Connect%s(''%s'',%d)',module,obj.ConnectionType,modid))
                    errordlg(sprintf(['Unable to connect to %s_%d module via %s connection!\n\n', ...
                        'Ensure all modules are powered on and connections are secured\n\n', ...
                        'Ensure the module is recognized in the zBusMon program.'], ...
                        module,modid,ct),'Connection Error','modal');
                    CloseUp(obj.handle,h);
                    return
                    
                else
                    fprintf('%s_%d connected ... ',module,modid)
                    obj.handle.ClearCOF;
                    
                    if obj.Fs >= 0
                        e = obj.handle.LoadCOFsf(rpfile,obj.Fs);
                    else
                        e = obj.handle.LoadCOF(rpfile);
                    end
                    
                    if ~e
                        errordlg(sprintf(['Unable to load RPvds file to %s module!\n\n', ...
                            'The RPvds file exists, but can not be loaded for some reason'], ...
                            module),'Loading Error','modal');
                        obj.cleanup;
                        return
                    end
                end
            end

        end

        function run(obj)
            for i = 1:length(obj.handle)
                if obj.handle(i).Run
                    fprintf('running\n')
                else
                    errordlg(sprintf(['Unable to run %s module!\n\n', ...
                        'Ensure all modules are powered on and connections are secured'], ...
                        module),'Run Error','modal');
                    obj.cleanup;
                    return
                end
            end
        end
        
        function stop(obj)
            for i = 1:length(obj.handle)
                obj.handle(i).Halt;
            end
            obj.cleanup;
        end
        
        function cleanup(obj)
            delete(obj.handle);
            h = findobj('Name','RPfig');
            close(h);
        end

        function status = get.Status(obj)
            if isa(obj.handle,obj.Type)
                for i = 1:length(obj.handle)
                    rpstatus = obj.handle(i).GetStatus;
                    if rpstatus == 7
                        status = hardware.Status.Running;

                    elseif rpstatus == 3
                        status = hardware.Status.Ready;
                        return

                    else
                        status = hardware.Status.InPrep;
                        return
                    end
                end
            else
                status = hardware.Status.Error;
            end
        end % get.Status

        function i = get.FsInt(obj)
            mfs = 390625;
            fs = mfs ./ 2.^(0:6);
            i = obj.Fs == fs;
        end
    end
end