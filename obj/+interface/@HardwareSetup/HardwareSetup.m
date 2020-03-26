classdef HardwareSetup < handle

    properties
        ConnectorDropDown    matlab.ui.control.DropDown
        ConnectorLabel       matlab.ui.control.Label
        HWSpecificPanel      matlab.ui.container.Panel
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
            c = hardware.Hardware.available;
            if isempty(p), p = c{1}; end
            i = ismember(c,p);
            hObj.Items = c;
            hObj.Value = c{i};
        end
        
        function value_changed(obj,hObj,ev)
            v = hObj.Value;
            setpref('interface_ConnectorSetup','dfltConnector',v);

            % TODO: call connector to setup HWSpecificPanel
        end
    end

end