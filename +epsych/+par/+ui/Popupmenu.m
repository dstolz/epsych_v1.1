classdef Popupmneu < epsych.par.ui.Control
    
    properties         
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'popupmenu';
    end

    methods
        function obj = Popupmneu(varargin)
            obj = obj@epsych.par.ui.Control(varargin{:});
            obj.ValueType = obj.ValueType;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.par.(obj.ValueType);
        end
    end

end