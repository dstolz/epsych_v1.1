classdef TDTActiveX < connector.Connector

    properties
        Name (1,:) char = 'TDTActiveX';
        Type (1,:) char = 'COM.RPco_x';
        Description (1,:) char = 'Standalone TDT ActiveX controls';
        State (1,1) epsych.State = epsych.State.Prep;

        ConnectionType (1,:) char {mustBeMember(ConnectionType,{'GB','USB'})} = 'GB';
        Module         (:,1) cell {mustBeMember(Module,{'Undefined','RP2','RA16','RL2','RV8','RX5','RX6','RX7','RX8','RZ2','RZ5','RZ6','RM1','RM2'})} = 'Undefined';
        ModuleID       (:,1) double {mustBePositive,mustBeInteger} = 1;
        RPvdsFile      (1,:) char
        Fs             (1,1) double {mustBeInteger} = -1; % -1 : not specified
    end

    properties (Dependent)
        Status
    end

    properties (Access = private)
        emptyFig
    end

    methods
        function obj = TDTActiveX
            % call superclass constructor
            obj = obj@connector.Connector;
        end

        function set.State(obj,newState)
            switch newState
                case 'Prep'
                    obj.prepare;

                case {'Run','Preview'}
                    obj.
                case 'Pause'

                case 'Halt'

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
            
            if obj.Status == connector.Status.Running
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
        
        function cleanup(obj)
            delete(obj.handle);
            h = findobj('Name','RPfig');
            close(h);
        end

        function status = get.Status(obj)
            if isa(obj.handle,obj.Type)
                rpstatus = double(obj.handle.GetStatus);
                if bitget(rpstatus,3)
                    status = connector.Status.Running;

                elseif isempty(obj.RPvdsFile)
                    status = connector.Status.InPrep;

                else
                    status = connector.Status.Ready;
                end
            else
                status = connector.Status.Error;
            end
        end
    end
end