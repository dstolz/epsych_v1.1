classdef Listbox < epsych.par.ui.Control
    
    properties
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'listbox';
    end

    methods
        function obj = Listbox(varargin)
            obj = obj@epsych.par.ui.Control(varargin{:});
            obj.ValueType = obj.ValueType;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.par.(obj.ValueType);
            obj.hControl.Value = 1;
            obj.hControl.Min = 1;
            obj.hControl.Max = 100 * obj.epsych.par.isMultiselect;
        end
        
        
        
    end

end