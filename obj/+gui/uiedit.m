classdef uiedit < gui.ParameterControl
    
    properties 
        ValueType = 'Expression';
    end
    
    properties (Constant)
        Style = 'edit';
    end

    methods
        function obj = uiedit(varargin)
            obj = obj@gui.ParameterControl(varargin{:});
            obj.Position  = [0 0 150 25];
            obj.ValueType = obj.ValueType;
        end        
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Expression','Value','ValueStr','Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = h.Parameter.(obj.ValueType);
        end
        
        function modify_parameter(obj,hObj,event)
            disp(event)
        end
        
        function Callback(obj,hObj,event)
            disp(event)
        end
    end

end