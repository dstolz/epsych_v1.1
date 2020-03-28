classdef HardwareSetup < handle

    properties (SetAccess = protected)
        HWInterface
    end

    properties (Access = protected)
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

            obj.HWInterface = c{i};
        end
        
        function set.HWInterface(obj,c)
            try
                delete(obj.HWInterface);
            end
            
            % instantiate hardware object
            obj.HWInterface = hardware.(c);
            obj.HWInterface.setup(obj.HWSpecificPanel);
            
            setpref('interface_ConnectorSetup','dfltConnector',c);
        end
    end

end