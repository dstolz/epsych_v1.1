classdef ControlPanel < handle
    
    properties
        Runtime % handle to epsych.expt.Runtime
    end
    
    properties (Access = protected)
        RuntimePanel        matlab.ui.container.Panel
        ToolbarPanel        matlab.ui.container.Panel

        LoadButton          matlab.ui.control.Button
        SaveButton          matlab.ui.control.Button
        BitmaskDesignButton matlab.ui.control.Button
        ParameterizeButton  matlab.ui.control.Button
        
        AlwaysOnTopCheckbox     % epsych.ui.FigOnTop
    end
    
    properties (SetAccess = private, Hidden)
        parent              % any matlab.ui.container
    end
    
    methods
        % Constructor
        function obj = ControlPanel(varargin)
            global RUNTIME
            
            parent = [];
            filename = '';
            
            for i = 1:length(varargin)
                v = varargin{i};
                if isstring(v) || ischar(v)
                    filename = char(v);
                elseif contains(class(v),'container','IgnoreCase',false) || endsWith(class(v),'Figure','IgnoreCase',false)
                    parent = v;
                else
                    error('epsych:ui:ControlPanel:InvalidInput','Inputs to epsych.ui.ControlPanel may be filename and/or parent container')
                    clear obj %#ok<UNRCH>
                    return
                end
            end
            
            % INITIALIZE RUNTIME OBJECT
            if isempty(RUNTIME) || ~isvalid(RUNTIME)
                RUNTIME = epsych.expt.Runtime;
                
                addlistener(RUNTIME,'RuntimeConfigChange',@obj.listener_RuntimeConfigChange);
                addlistener(RUNTIME,'PreStateChange',@obj.listener_PreStateChange);
                addlistener(RUNTIME,'PostStateChange',@obj.listener_PostStateChange);
            end
            
            % INITIALIZE SESSION LOG
            if isempty(RUNTIME.Log) || ~isvalid(RUNTIME.Log)
                fn = sprintf('EPsychLog_%s.txt',datestr(now,30));
                RUNTIME.Log = epsych.log.Log(fullfile(RUNTIME.Config.LogDirectory,fn));
            end

            obj.Runtime = RUNTIME;
            
            % permit only one instance at a time
            f = epsych.Tool.find_epsych_controlpanel;
            if isempty(f)
                log_write('Important','Launching EPsych GUI')
                obj.create(parent);

                drawnow

                loadConfig = getpref('epsych_Config','AutoLoadRuntimeConfig',true);
                if isempty(filename) && loadConfig
                    filename = getpref('epsych_Config','AutoLoadRuntimeConfigFile',fullfile(epsych.Info.user_directory,'AutoLoadRuntimeConfig.mat'));
                end
                
                set(ancestor(obj.parent,'figure'),'Tag','EPsychControlPanel'); % required
            else
                figure(f);
            end
            
            if ~isempty(filename)
                obj.load_config(filename);
            end
            
            
            % elevate Matlab.exe process to a high priority in Windows
            pid = feature('getpid');
            [~,msg] = dos(sprintf('wmic process where processid=%d CALL setpriority 128',pid));
            log_write('Debug',msg);

            
            if nargout == 0, clear obj; end
        end
        

        % Destructor
        function delete(obj)
            
            if obj.Runtime.Config.AutoSaveRuntimeConfig
                obj.save_config('default');
            end
            
            log_write('Important','ControlPanel closing.')
            
            drawnow
                                    
            delete(obj.Runtime);
            
            
            % be nice and return Matlab.exe process to normal priority in Windows
            pid = feature('getpid');
            [~,~] = dos(sprintf('wmic process where processid=%d CALL setpriority 32',pid));
            
            clear global RUNTIME
        end
        
        function closereq(obj,hObj,event)
            log_write(epsych.log.Verbosity.Important,'ControlPanel close requested.')
            
            if obj.Runtime.isRunning
                uialert(ancestor(obj.parent,'figure'), ...
                    'Please Halt the experiment before closing the Control Panel.','Close', ...
                    'Icon','warning');
                return
            end
            
            if ~obj.Runtime.ConfigIsSaved
                if obj.Runtime.Config.AutoSaveRuntimeConfig
                    obj.save_config('default');
                    
                else
                    r = uiconfirm(obj.parent,'There have been changes made to the current configuration.  Would you like to save the current configuration before exiting EPsych?', ...
                        'Save Config','Icon','question', ...
                        'Options',{'Save','Continue','Cancel'}, ...
                        'DefaultOption','Save','CancelOption','Cancel');
                    switch r
                        case 'Save'
                            obj.save_config;
                            
                        case 'Cancel'
                            return
                            
                        case 'Continue'
                            log_write('Insanity','User chose to not save Runtime config on close')
                    end
                end
            end
            
            setpref('epsych_ControlPanel','Position',obj.parent.Position);
            
            delete(obj.parent);
            delete(obj);
        end
        
        function save_config(obj,ffn,~,~)            
            prevState = epsych.Tool.figure_state(obj.parent,false);
            
            pn = getpref('epsych_Config','configPath',obj.Runtime.Config.UserDirectory);
            if nargin == 1 || isequal(ffn,'default')
                ffn = fullfile(pn,'EPsychRuntimeConfig.mat');
            elseif ishandle(ffn) % coming from callback
                ffn = [];
            end
            
            if isempty(ffn)
                [fn,pn] = uiputfile( ...
                    {'*.epcf', 'EPsych Configuration File'}, ...
                    'Select Configuration File', ...
                    pn);
                
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
            end

            log_write(epsych.log.Verbosity.Verbose,'Saving EPsych Runtime Config as "%s"',ffn);
            
            RUNTIME = obj.Runtime;
            save(ffn,'RUNTIME','-mat');

            [pn,~] = fileparts(ffn);
            setpref('epsych_Config','configPath',pn);
            
            if ~isempty(obj.parent) && isvalid(obj.parent)
                figure(obj.parent);
                epsych.Tool.figure_state(obj.parent,prevState);
            end
        end
        
        
        function load_config(obj,ffn,~,~)
            global RUNTIME
            
            if ~obj.Runtime.ConfigIsSaved
                r = uiconfirm(obj.parent,'There have been changes made to the current configuration.  Would you like to first save the current configuration?', ...
                    'Load Config','Icon','question', ...
                    'Options',{'Save','Continue','Cancel'}, ...
                    'DefaultOption','Save','CancelOption','Cancel');
                switch r
                    case 'Save'
                        obj.save_config;

                    case 'Cancel'
                        return

                    case 'Continue'
                        log_write(epsych.log.Verbosity.Verbose,'User chose to not save the current configuration.')
                end
            end
            
            if nargin == 1 || isequal(ffn,'default')
                ffn = fullfile(obj.Runtime.Config.UserDirectory,'EPsychRuntimeConfig.mat');
                if ~isfile(ffn), ffn = []; end

            elseif ishandle(ffn) % coming from callback
                ffn = [];
            end
            
            if isempty(ffn)
                pn = getpref('epsych_Config','configPath',cd);
                [fn,pn] = uigetfile( ...
                    {'*.epcf', 'EPsych Configuration File'}, ...
                    'Select Configuration File', ...
                    pn);
                
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
            end

            fig = ancestor(obj.parent,'figure');
            fig.Pointer = 'watch'; drawnow
            
            hl = obj.Runtime.AutoListeners__; % undocumented
            hl(cellfun(@(a) isequal(class(a),'event.proplistener'),hl)) = [];

            log_write('Debug','Disabling %d listeners',length(hl))
            for i = 1:length(hl), hl{i}.Enabled = 0; end
            
            warning('off','MATLAB:class:mustReturnObject');
            x = who('-file',ffn,'RUNTIME');
            warning('on','MATLAB:class:mustReturnObject');
            
            if isempty(x)
                log_write('Verbose','Invalid Config file: %s',ffn)
                log_write('Error','Unable to load the configuration: "%s"',ffn);
                log_write('GUIerror','Unable to load the configuration:\n\n"%s"',ffn);
                return
            end
            
            log = RUNTIME.Log;
            
            load(ffn,'-mat','RUNTIME');
            
            RUNTIME.Log = copy(log);
            obj.Runtime = RUNTIME;

            for i = 1:length(hl)
                addlistener(obj.Runtime,hl{i}.EventName,hl{i}.Callback);
            end

            log_write('Verbose','Loaded Runtime Config file: %s',ffn)

            [pn,fn] = fileparts(ffn);
            setpref('epsych_Config','configPath',pn);
            
            fig.Name = sprintf('EPsych Control Panel - "%s"',fn);
            
            
            log_write('Debug','notify "RuntimeConfigChange" after load config')
            notify(obj.Runtime,'RuntimeConfigLoaded');
            
            notify(obj.Runtime,'RuntimeConfigChange');
            
            figure(fig); % unhide gui
            fig.Pointer = 'arrow';
        end
        

    end
    
    methods (Access = private)
        create(obj,parent,reset);

        function listener_RuntimeConfigChange(obj,hObj,event)
            if isempty(obj.SaveButton), return; end % may not be instantiated yet

            if isvalid(obj.SaveButton) % prevents errors on autosave on close
                obj.SaveButton.Enable = 'on';
            end
            
            if hObj.State < epsych.enState.Ready
                if hObj.ReadyToBegin
                    hObj.State = epsych.enState.Ready;
                else
                    hObj.State = epsych.enState.Prep;
                end
            end

            log_write('Verbose','obj.Runtime Config updated')            
        end


        function listener_PreStateChange(obj,hObj,event)           
            if ~isvalid(obj.LoadButton), return; end
            
            % update GUI component availability
            if event.State == epsych.enState.Run
                log_write('Debug','Disabling ControlPanel interface');
                
                obj.LoadButton.Enable = 'off';
                obj.SaveButton.Enable = 'off';
            end
        end

        
        function listener_PostStateChange(obj,hObj,event)
            if ~isvalid(obj.LoadButton), return; end
            
            % update GUI component availability
            if any(event.State == [epsych.enState.Prep epsych.enState.Halt epsych.enState.Error])
                log_write('Debug','Enabling ControlPanel interface');

                obj.LoadButton.Enable = 'on';
            end
        end


        function launch_bitmaskgen(obj,hObj,event)
            log_write('Debug','Launching epsych.ui.BitmaskGen')

            epsych.ui.BitmaskGen;
        end

        function launch_exptparameterization(obj,hObj,event)
            log_write('Debug','Launching epsych.ui.BitmaskGen')

            ep_ExperimentDesign;
        end
    end
    
end