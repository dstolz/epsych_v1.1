classdef UICheckbox < parameter.UIControl
    
    properties
        ValueType = 'Value';
    end
    
    properties (Constant)
        Style = 'UICheckbox';
    end

    methods
        function obj = UICheckbox(varargin)
            obj = obj@parameter.UIControl(varargin{:});
            obj.hControl.Value = obj.Parameter.Value;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values'})
            obj.ValueType = type;
            obj.hControl.String = obj.Parameter.(obj.ValueType);
        end
        
    end

end