classdef uiedit < gui.ParameterControl
    
    properties 
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'edit';
    end

    methods
        function obj = uiedit(varargin)
            obj = obj@gui.ParameterControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end        
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Expression','Value','ValueStr','Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.Parameter.(obj.ValueType);
        end
        
    end

end