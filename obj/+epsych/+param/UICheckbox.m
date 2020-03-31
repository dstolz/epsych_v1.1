classdef UICheckbox < epsych.param.UIControl
    
    properties
        ValueType = 'Value';
    end
    
    properties (Constant)
        Style = 'UICheckbox';
    end

    methods
        function obj = UICheckbox(varargin)
            obj = obj@epsych.param.UIControl(varargin{:});
            obj.hControl.Value = obj.epsych.param.Value;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.param.(obj.ValueType);
        end
        
    end

end