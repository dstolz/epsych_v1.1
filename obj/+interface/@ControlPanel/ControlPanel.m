classdef ControlPanel < handle
    
    properties (Access = protected)
        parent           % any matlab.ui.container
        TabGroup         matlab.ui.container.TabGroup
        SubjectTab       matlab.ui.container.Tab
        HardwareTab      matlab.ui.container.Tab
        CustomizationTab matlab.ui.container.Tab
        LogTab           matlab.ui.container.Tab

        RuntimePanel     matlab.ui.container.Panel
        
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
            delete(RUNTIME.Log);
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

            delete(obj.parent);
            delete(obj);
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