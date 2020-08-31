classdef ControlPanel < handle
    
    properties        
        OverviewObj             % epsych.ui.OverviewSetup
        RuntimeControlObj       % epsych.ui.RuntimeControl
        SubjectSetupObj         % epsych.ui.SubjectSetup
        HardwareSetupObj        % epsych.ui.HardwareSetup
        RuntimeConfigSetupObj   % epsych.ui.ConfigSetup
        ShortcutsObj            % epsych.ui.Shortcuts
        
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
    
    properties (SetAccess = private)
        parent              % any matlab.ui.container
    end
    
    methods
        % Constructor
        function obj = ControlPanel(parent)
            global RUNTIME
            
            if nargin == 0, parent = []; end

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
                if loadConfig
                    obj.load_config;
                end
                
                set(ancestor(obj.parent,'figure'),'Tag','EPsychControlPanel'); % required
            else
                figure(f);
            end
            
                       
            if nargout == 0, clear obj; end
        end
        

        % Destructor
        function delete(obj)
            log_write('Important','ControlPanel closing.')
            
            drawnow
                        
            delete(obj.Runtime);
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
            
            delete(obj.parent);
            delete(obj);
        end
        
        function save_config(obj,ffn,~,~)            
            prevState = epsych.Tool.figure_state(obj.parent,false);
            
            if nargin == 1 || isequal(ffn,'default')
                ffn = fullfile(obj.Runtime.Config.UserDirectory,'EPsychRuntimeConfig.mat');
            elseif ishandle(ffn) % coming from callback
                ffn = [];
            end
            
            if isempty(ffn)
                pn = getpref('epsych_Config','configPath',cd);
                [fn,pn] = uiputfile( ...
                    {'*.epcf', 'EPsych Configuration File'}, ...
                    'Select Configuration File', ...
                    pn);
                
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
            end

            log_write(epsych.log.Verbosity.Verbose,'Saving EPsych Runtime Config as "%s"',ffn);
            
            save(ffn,'obj.Runtime','-mat');

            [pn,~] = fileparts(ffn);
            setpref('epsych_Config','configPath',pn);
            
            figure(obj.parent);
            epsych.Tool.figure_state(obj.parent,prevState);
        end
        
        
        function load_config(obj,ffn,~,~)
            

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
            
            warning('off','MATLAB:class:mustReturnObject');
            x = who('-file',ffn,'obj.Runtime');
            warning('on','MATLAB:class:mustReturnObject');
            
            if isempty(x)
                log_write('Verbose','Invalid Config file: %s',ffn)
                fprintf(2,'Unable to load the configuration: "%s"\n',ffn);
                return
            end
            
            hl = obj.Runtime.AutoListeners__; % undocumented

            load(ffn,'-mat','obj.Runtime');

            for i = 1:length(hl)
                if isequal(class(hl{i}),'event.proplistener')
                    addlistener(obj.Runtime,hl{1}.Source{1}.Name,hl{i}.EventName,hl{i}.Callback);
                else
                    addlistener(obj.Runtime,hl{i}.EventName,hl{i}.Callback);
                end
            end
            
            
            log_write('Verbose','Loaded Runtime Config file: %s',ffn)

            [pn,~] = fileparts(ffn);
            setpref('epsych_Config','configPath',pn);
            
            obj.reset_ui_objects;
            
            notify(obj.Runtime,'RuntimeConfigChange');
            
            figure(obj.parent); % unhide gui
        end
        
        
        function reset_ui_objects(obj)
            if ~isempty(obj.Runtime.Config)
                obj.RuntimeConfigSetupObj.Config = obj.Runtime.Config;
            end

            if ~isempty(obj.Runtime.Subject)
                obj.SubjectSetupObj.Subject = obj.Runtime.Subject;
            end

            if ~isempty(obj.Runtime.Hardware)
                obj.HardwareSetupObj.Hardware = obj.Runtime.Hardware;
            end
            
            
        end
        

    end
    
    methods (Access = private)
        create(obj,parent,reset);

        function listener_RuntimeConfigChange(obj,hObj,event)
            if isempty(obj.SaveButton), return; end % may not be instantiated yet
            
            obj.SaveButton.Enable = 'on';
            
            if  hObj.State == epsych.enState.Prep && hObj.ReadyToBegin
                hObj.State = epsych.enState.Ready;
            end

            log_write('Verbose','obj.Runtime Config updated')
        end


        function listener_PreStateChange(obj,hObj,event)           
            % update GUI component availability
            if event.State == epsych.enState.Run
                log_write('Debug','Disabling ControlPanel interface');
                
                obj.LoadButton.Enable = 'off';
                obj.SaveButton.Enable = 'off';
            end
        end

        
        function listener_PostStateChange(obj,hObj,event)            
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