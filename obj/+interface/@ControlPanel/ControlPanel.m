classdef ControlPanel < handle
    
    properties (Access = protected)
        parent           % any matlab.ui.container
        TabGroup         matlab.ui.container.TabGroup
        SubjectTab       matlab.ui.container.Tab
        HardwareTab      matlab.ui.container.Tab
        CustomizationTab matlab.ui.container.Tab
        LogTab           matlab.ui.container.Tab
        
        RuntimePanel     matlab.ui.container.Panel
        ConfigPanel      matlab.ui.container.Panel
        
        RuntimeControlObj       % interface.RuntimeControl
        SubjectSetupObj         % interface.SubjectSetup
        HardwareSetupObj        % interface.HardwareSetup
        CustomizationSetupObj   % interface.CustomizationSetup
    end
    
    methods
        % Constructor
        function obj = ControlPanel(parent)
            global RUNTIME
            
            if nargin == 0, parent = []; end
            
            
            % permit only one instance at a time
            f = epsych.Tool.find_epsych_controlpanel;
            if isempty(f)
                % INITIALIZE RUNTIME OBJECT
                RUNTIME = epsych.Runtime;
                
                obj.create(parent);
                set(ancestor(obj.parent,'figure'),'Tag','EPsychControlPanel'); % required
            else
                figure(f);
            end
            
        end
        
        % Destructor
        function delete(obj)
            global RUNTIME
            
            RUNTIME.Log.write(log.Verbosity.Important,'ControlPanel closing.')
            
            drawnow
            
            delete(RUNTIME);
        end
        
        function closereq(obj,hObj,event)
            global RUNTIME
            
            RUNTIME.Log.write(log.Verbosity.Important,'ControlPanel close requested.')
            
            if ~any(RUNTIME.State == [epsych.State.Halt, epsych.State.Prep])
                uialert(ancestor(obj.parent,'figure'),'Close', ...
                    'Please Halt the experiment before closing the Control Panel.');
                return
            end
            
            if RUNTIME.Config.AutoSaveRuntimeConfig
                obj.save_config('default');
            end
            
            delete(obj.parent);
            delete(obj);
        end
        
        function save_config(obj,ffn,~,~)
            global RUNTIME
            
            
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
            
            RUNTIME.Log.write(log.Verbosity.Verbose,'Saving EPsych Runtime Config as "%s"',ffn);
            
            Config = RUNTIME.Config;
            save(ffn,'Config','-mat');
        end
        
        
        function load_config(obj,ffn,~,~)
            global RUNTIME
            
            if nargin == 1
                ffn = fullfile(RUNTIME.Config.UserDirectory,'EPsychRuntimeConfig.mat');
                if ~isfile(ffn)
                    ffn = [];
                end
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
            
            RUNTIME.Log.write(log.Verbosity.Verbose,'Loading Runtime Config file: %s',ffn)
            load(ffn,'-mat','Config');
            
            RUNTIME.Config = Config;
            
            obj.create(obj.parent,true);
        end
        
        
        
        function collect_config(obj)
            % collect Hardware config
            
            % collect Customized functionality
            C = obj.CustomizationSetupObj
            
            
            % collect Subject data
            
        end
        
        
        
        
    end
    
    methods (Access = private)
        create(obj,parent,reset);
    end
    
end