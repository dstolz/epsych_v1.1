classdef UIListbox < epsych.param.UIControl
    
    properties
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'listbox';
    end

    methods
        function obj = UIListbox(varargin)
            obj = obj@epsych.param.UIControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.param.(obj.ValueType);
            obj.hControl.Value = 1;
            obj.hControl.Min = 1;
            obj.hControl.Max = 100 * obj.epsych.param.isMultiselect;
        end
        
        
        
    end

end