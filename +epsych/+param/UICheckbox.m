classdef uiCheckbox < epsych.param.uiControl
    
    properties
        ValueType = 'Value';
    end
    
    properties (Constant)
        Style = 'uiCheckbox';
    end

    methods
        function obj = uiCheckbox(varargin)
            obj = obj@epsych.param.uiControl(varargin{:});
            obj.hControl.Value = obj.epsych.param.Value;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.param.(obj.ValueType);
        end
        
    end

end