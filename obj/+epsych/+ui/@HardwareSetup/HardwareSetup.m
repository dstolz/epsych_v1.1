classdef HardwareSetup < handle

    properties
        Hardware
    end

    properties (Access = protected)
        HardwareDropDown       matlab.ui.control.DropDown
        HardwareLabel          matlab.ui.control.Label
        HardwarePanel           matlab.ui.container.Panel
        HWDescriptionTextArea   matlab.ui.control.TextArea
    end

    
    properties (SetAccess = immutable)
        parent
    end


    methods
        create(obj,parent);
        
        function obj = HardwareSetup(parent)
            obj.create(parent);
            obj.parent = parent;
        end

        
        function create_dropdown(obj,hObj,~)
            p = getpref('interface_HardwareSetup','dfltHardware',[]);
            c = epsych.hw.Hardware.available;
            if isempty(p), p = c{1}; end
            if isobject(p)
                i = ismember(c,p.Name);
            else
                i = ismember(c,p);
            end
            hObj.Items = c;
            hObj.Value = c{i};

            obj.Hardware = c{i};
        end

        function value_changed(obj,hObj,event)
            obj.Hardware = hObj.Value;
        end
        
        function set.Hardware(obj,hw)
            global RUNTIME

            try, delete(obj.Hardware); end
            try, delete(obj.HardwarePanel.Children); end
            
            % instantiate hardware object
            if ischar(hw)
                obj.Hardware = epsych.hw.(hw);
            else
                obj.Hardware = hw;
            end
            obj.Hardware.setup(obj.HardwarePanel);
            v = sprintf('Type: %s\n%s',obj.Hardware.Type,obj.Hardware.Description);
            obj.HWDescriptionTextArea.Value = v;

            RUNTIME.Hardware = copy(obj.Hardware);
            
            setpref('interface_HardwareSetup','dfltHardware',hw);
        end
    end

end