classdef uicheckbox < gui.ParameterControl
    
    properties
        ValueType = 'Value';
    end
    
    properties (Constant)
        Style = 'uicheckbox';
    end

    methods
        function obj = uicheckbox(varargin)
            obj = obj@gui.ParameterControl(varargin{:});
            
            obj.hControl.Value = obj.Parameter.Value;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values'})
            obj.ValueType = type;
            obj.hControl.String = obj.Parameter.(obj.ValueType);
        end
        
        function modify_parameter(obj,hObj,event)
            disp(event)
        end
        
        function Callback(obj,hObj,event)
            disp(event)
        end
    end

end