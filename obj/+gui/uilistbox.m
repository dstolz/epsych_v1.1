classdef uilistbox < gui.ParameterControl
    
    properties
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'listbox';
    end

    methods
        function obj = uilistbox(varargin)
            obj = obj@gui.ParameterControl(varargin{:});
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
        
        
        function modify_parameter(obj,hObj,event)
            disp(event)
        end
        
        function Callback(obj,hObj,event)
            disp(event)
        end
        
    end

end