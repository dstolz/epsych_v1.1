classdef uipopupmenu < gui.ParameterControl
    
    properties         
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'popupmenu';
    end

    methods
        function obj = uipopupmenu(varargin)
            obj = obj@gui.ParameterControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values','ValuesStr'})
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