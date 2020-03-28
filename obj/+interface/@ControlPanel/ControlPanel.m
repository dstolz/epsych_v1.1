classdef ControlPanel < handle
    
    properties (Access = protected)
        parent           % any matlab.ui.container
        TabGroup         matlab.ui.container.TabGroup
        SubjectTab       matlab.ui.container.Tab
        HardwareTab      matlab.ui.container.Tab
        CustomizationTab matlab.ui.container.Tab

        RuntimePanel     matlab.ui.container.Panel
        
        RuntimeControlObj       % interface.RuntimeControl
        SubjectSetupObj         % interface.SubjectSetup
        HardwareSetupObj        % interface.HardwareSetup
        CustomizationSetupObj   % interface.CustomizationSetup
    end
    
    methods
        function obj = ControlPanel(parent)
            if nargin == 0, parent = []; end

            f = findobj('Tag','EPsychControlPanel');
            if isempty(f)
                obj.create(parent);
                obj.parent.Tag = 'EPsychControlPanel';
            else
                figure(f);
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