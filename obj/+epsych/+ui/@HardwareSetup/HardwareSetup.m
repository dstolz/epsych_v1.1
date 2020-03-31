classdef HardwareSetup < handle

    properties (SetAccess = protected)
        HWInterface
    end

    properties (Access = protected)
        ConnectorDropDown       matlab.ui.control.DropDown
        ConnectorLabel          matlab.ui.control.Label
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
            p = getpref('interface_ConnectorSetup','dfltConnector',[]);
            c = epsych.hw.Hardware.available;
            if isempty(p), p = c{1}; end
            i = ismember(c,p);
            hObj.Items = c;
            hObj.Value = c{i};

            obj.HWInterface = c{i};
        end

        function value_changed(obj,hObj,event)
            obj.HWInterface = hObj.Value;
        end
        
        function set.HWInterface(obj,c)
            try, delete(obj.HWInterface); end
            try, delete(obj.HardwarePanel.Children); end
            
            % instantiate hardware object
            obj.HWInterface = epsych.hw.(c);
            obj.HWInterface.setup(obj.HardwarePanel);
            v = sprintf('Type: %s\n%s',obj.HWInterface.Type,obj.HWInterface.Description);
            obj.HWDescriptionTextArea.Value = v;
            
            setpref('interface_ConnectorSetup','dfltConnector',c);
        end
    end

end