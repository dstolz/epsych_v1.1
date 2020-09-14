classdef Checkbox < epsych.par.ui.Control
    
    properties
        ValueType = 'Value';
    end
    
    properties (Constant)
        Style = 'Checkbox';
    end

    methods
        function obj = Checkbox(varargin)
            obj = obj@epsych.par.ui.Control(varargin{:});
            obj.hControl.Value = obj.epsych.par.Value;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.par.(obj.ValueType);
        end
        
    end

end