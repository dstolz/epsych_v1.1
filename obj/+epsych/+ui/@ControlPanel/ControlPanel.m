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

            % permit only one instance at a time
            f = epsych.Tool.find_epsych_controlpanel;
            if isempty(f)
                % INITIALIZE RUNTIME OBJECT
                RUNTIME = epsych.expt.Runtime;
                
                % INITIALIZE SESSION LOG
                fn = sprintf('EPsychLog_%s.txt',datestr(now,30));
                LOG = epsych.log.Log(fullfile(RUNTIME.Config.LogDirectory,fn));
                
                addlistener(RUNTIME,'RuntimeConfigChange',@obj.config_change_detected);

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
            
            if ~any(RUNTIME.State == [epsych.enState.Halt, epsych.enState.Prep])
                uialert(ancestor(obj.parent,'figure'),'Close', ...
                    'Please Halt the experiment before closing the Control Panel.');
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
                [fn,pn] = uiputfile( ...
                    {'*.epcf', 'EPsych Configuration File'}, ...
                    'Select Configuration File', ...
                    RUNTIME.Config.UserDirectory);
                
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
            end

            LOG.write(epsych.log.Verbosity.Verbose,'Saving EPsych Runtime Config as "%s"',ffn);
            
            save(ffn,'RUNTIME','-mat');

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
                [fn,pn] = uigetfile( ...
                    {'*.epcf', 'EPsych Configuration File'}, ...
                    'Select Configuration File', ...
                    RUNTIME.Config.UserDirectory);
                
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
            end
            
            warning('off','MATLAB:class:mustReturnObject');
            x = who('-file',ffn,'RUNTIME');
            warning('on','MATLAB:class:mustReturnObject');
            
            if isempty(x)
                LOG.write(epsych.log.Verbosity.Verbose,'Invalid Config file: %s',ffn)
                fprintf(2,'Unable to load the configuration: "%s"\n',ffn);
                return
            end

            load(ffn,'-mat','RUNTIME');

            addlistener(RUNTIME,'RuntimeConfigChange',@obj.config_change_detected);

            LOG.write(epsych.log.Verbosity.Verbose,'Loaded Runtime Config file: %s',ffn)

            obj.reset_ui_objects;
            
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

        function config_change_detected(obj,hObj,~)
            if isempty(obj.SaveButton), return; end % may not be instantiated yet
            if hObj.ConfigIsSaved
                obj.SaveButton.Enable = 'off';
            else
                obj.SaveButton.Enable = 'on';
            end
        end
    end
    
end