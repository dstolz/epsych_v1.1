classdef ControlPanel < handle
    
    properties (Access = protected)
        parent           % any matlab.ui.container
        TabGroup         matlab.ui.container.TabGroup
        SubjectTab       matlab.ui.container.Tab
        HardwareTab      matlab.ui.container.Tab
        CustomizationTab matlab.ui.container.Tab
        LogTab           matlab.ui.container.Tab

        RuntimePanel     matlab.ui.container.Panel

        LogTextArea      matlab.ui.control.TextArea
        LogFilenameLabel matlab.ui.control.Label
        LogVerbosityDropDown matlab.ui.control.DropDown
        
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

            % permit one instance
            f = findall(0,'Tag','EPsychControlPanel');
            if isempty(f)
                obj.create(parent);
                obj.parent.Tag = 'EPsychControlPanel';
                
                % INITIALIZE RUNTIME OBJECT
                RUNTIME = epsych.Runtime;
                
                RUNTIME.Log.create_gui();
            else
                figure(f);
            end

            
        end

        % Destructor
        function delete(obj)
            global RUNTIME

            if ~any(RUNTIME.State == [epsych.State.Halt, epsych.State.Prep])
                uialert(ancestor(obj.parent,'figure'),'Close', ...
                    'Please Halt the experiment before closing the Control Panel.');
                return
            end

        end

        


        function collect_config(obj)
            % collect Hardware config

            % collect Customized functionality

            % collect Subject data

        end




    end
    
    methods (Access = private)
        create(obj,parent);
    end
    
end