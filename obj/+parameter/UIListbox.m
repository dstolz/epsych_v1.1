classdef UIListbox < parameter.UIControl
    
    properties
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'listbox';
    end

    methods
        function obj = UIListbox(varargin)
            obj = obj@parameter.UIControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.Parameter.(obj.ValueType);
            obj.hControl.Value = 1;
            obj.hControl.Min = 1;
            obj.hControl.Max = 100 * obj.Parameter.isMultiselect;
        end
        
        
        
    end

end