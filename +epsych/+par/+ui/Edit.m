classdef Edit < epsych.par.ui.Control
    
    properties 
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'edit';
    end

    methods
        function obj = Edit(varargin)
            obj = obj@epsych.par.ui.Control(varargin{:});
            obj.ValueType = obj.ValueType;
        end        
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Expression','Value','ValueStr','Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.par.(obj.ValueType);
        end
        
    end

end