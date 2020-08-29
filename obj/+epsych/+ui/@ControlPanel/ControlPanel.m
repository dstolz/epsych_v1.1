classdef ControlPanel < handle
    
    properties (Access = protected)
        parent           % any matlab.ui.container

        TabGroup         matlab.ui.container.TabGroup
        OverviewTab      matlab.ui.container.Tab
        SubjectTab       matlab.ui.container.Tab
        HardwareTab      matlab.ui.container.Tab
        CustomizationTab matlab.ui.container.Tab
        LogTab           matlab.ui.container.Tab
        ShortcutsTab     matlab.ui.container.Tab
        
        RuntimePanel     matlab.ui.container.Panel
        ToolbarPanel     matlab.ui.container.Panel

        LoadButton       matlab.ui.control.Button
        SaveButton       matlab.ui.control.Button
        BitmaskDesignButton matlab.ui.control.Button
        ParameterizeButton  matlab.ui.control.Button
        
        AlwaysOnTopCheckbox     % epsych.ui.FigOnTop

        OverviewObj             % epsych.ui.OverviewSetup
        RuntimeControlObj       % epsych.ui.RuntimeControl
        SubjectSetupObj         % epsych.ui.SubjectSetup
        HardwareSetupObj        % epsych.ui.HardwareSetup
        RuntimeConfigSetupObj   % epsych.ui.ConfigSetup
        ShortcutsObj            % epsych.ui.Shortcuts
    end
    
    methods
        % Constructor
        function obj = ControlPanel(parent)
            global RUNTIME LOG
            
            if nargin == 0, parent = []; end

            % INITIALIZE RUNTIME OBJECT
            if isempty(RUNTIME) || ~isvalid(RUNTIME)
                RUNTIME = epsych.expt.Runtime;
                
                addlistener(RUNTIME,'RuntimeConfigChange',@obj.listener_RuntimeConfigChange);
                addlistener(RUNTIME,'PreStateChange',@obj.listener_PreStateChange);
                addlistener(RUNTIME,'PostStateChange',@obj.listener_PostStateChange);
            end
            
            % INITIALIZE SESSION LOG
            if isempty(LOG) || ~isvalid(LOG)
                fn = sprintf('EPsychLog_%s.txt',datestr(now,30));
                LOG = epsych.log.Log(fullfile(RUNTIME.Config.LogDirectory,fn));
            end

            % permit only one instance at a time
            f = epsych.Tool.find_epsych_controlpanel;
            if isempty(f)
                LOG.write('Important','Launching EPsych GUI')
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
            global RUNTIME LOG
            
            LOG.write('Important','ControlPanel closing.')
            
            drawnow
            
            delete(RUNTIME);

            delete(LOG);
        end
        
        function closereq(obj,hObj,event)
            global RUNTIME LOG
            
            LOG.write(epsych.log.Verbosity.Important,'ControlPanel close requested.')
            
            if RUNTIME.isRunning
                uialert(ancestor(obj.parent,'figure'), ...
                    'Please Halt the experiment before closing the Control Panel.','Close', ...
                    'Icon','warning');
                return
            end
            
            if ~RUNTIME.ConfigIsSaved
                if RUNTIME.Config.AutoSaveRuntimeConfig
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
                            LOG.write('Insanity','User chose to not save Runtime config on close')
                    end
                end
            end
            
            delete(obj.parent);
            delete(obj);
        end
        
        function save_config(obj,ffn,~,~)
            global RUNTIME LOG
            
            prevState = epsych.Tool.figure_state(obj.parent,false);
            
            if nargin == 1 || isequal(ffn,'default')
                ffn = fullfile(RUNTIME.Config.UserDirectory,'EPsychRuntimeConfig.mat');
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

            LOG.write(epsych.log.Verbosity.Verbose,'Saving EPsych Runtime Config as "%s"',ffn);
            
            save(ffn,'RUNTIME','-mat');

            [pn,~] = fileparts(ffn);
            setpref('epsych_Config','configPath',pn);
            
            figure(obj.parent);
            epsych.Tool.figure_state(obj.parent,prevState);
        end
        
        
        function load_config(obj,ffn,~,~)
            global RUNTIME LOG

            if ~RUNTIME.ConfigIsSaved
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
                        LOG.write(epsych.log.Verbosity.Verbose,'User chose to not save the current configuration.')
                end
            end
            
            if nargin == 1 || isequal(ffn,'default')
                ffn = fullfile(RUNTIME.Config.UserDirectory,'EPsychRuntimeConfig.mat');
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
            x = who('-file',ffn,'RUNTIME');
            warning('on','MATLAB:class:mustReturnObject');
            
            if isempty(x)
                LOG.write('Verbose','Invalid Config file: %s',ffn)
                fprintf(2,'Unable to load the configuration: "%s"\n',ffn);
                return
            end
            
            hl = RUNTIME.AutoListeners__; % undocumented

            load(ffn,'-mat','RUNTIME');

            for i = 1:length(hl)
                if isequal(class(hl{i}),'event.proplistener')
                    addlistener(RUNTIME,hl{1}.Source{1}.Name,hl{i}.EventName,hl{i}.Callback);
                else
                    addlistener(RUNTIME,hl{i}.EventName,hl{i}.Callback);
                end
            end
            
            
            LOG.write('Verbose','Loaded Runtime Config file: %s',ffn)

            [pn,~] = fileparts(ffn);
            setpref('epsych_Config','configPath',pn);
            
            obj.reset_ui_objects;
            
            notify(RUNTIME,'RuntimeConfigChange');
            
            figure(obj.parent); % unhide gui
        end
        
        
        function reset_ui_objects(obj)
            global RUNTIME

            if ~isempty(RUNTIME.Config)
                obj.RuntimeConfigSetupObj.Config = RUNTIME.Config;
            end

            if ~isempty(RUNTIME.Subject)
                obj.SubjectSetupObj.Subject = RUNTIME.Subject;
            end

            if ~isempty(RUNTIME.Hardware)
                obj.HardwareSetupObj.Hardware = RUNTIME.Hardware;
            end
            
            
        end
        

    end
    
    methods (Access = private)
        create(obj,parent,reset);

        function listener_RuntimeConfigChange(obj,hObj,event)
            if isempty(obj.SaveButton), return; end % may not be instantiated yet
            if hObj.ConfigIsSaved
                obj.SaveButton.Enable = 'off';
            else
                obj.SaveButton.Enable = 'on';
            end
            
            if  hObj.State == epsych.enState.Prep && hObj.ReadyToBegin
                hObj.State = epsych.enState.Ready;
            end
        end


        function listener_PreStateChange(obj,hObj,event)
            global LOG
            
            % update GUI component availability
            if event.State == epsych.enState.Run
                LOG.write('Debug','Disabling ControlPanel interface');
                
                obj.LoadButton.Enable = 'off';
                obj.SaveButton.Enable = 'off';
            end
        end

        
        function listener_PostStateChange(obj,hObj,event)
            global LOG
            
            % update GUI component availability
            if any(event.State == [epsych.enState.Prep epsych.enState.Halt epsych.enState.Error])
                LOG.write('Debug','Enabling ControlPanel interface');

                obj.LoadButton.Enable = 'on';
            end
        end


        function launch_bitmaskgen(obj,hObj,event)
            global LOG
            LOG.write('Debug','Launching epsych.ui.BitmaskGen')

            epsych.ui.BitmaskGen;
        end

        function launch_exptparameterization(obj,hObj,event)
            global LOG
            LOG.write('Debug','Launching epsych.ui.BitmaskGen')

            ep_ExperimentDesign;
        end
    end
    
end