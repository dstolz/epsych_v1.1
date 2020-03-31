classdef UIEdit < epsych.param.UIControl
    
    properties 
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'edit';
    end

    methods
        function obj = UIEdit(varargin)
            obj = obj@epsych.param.UIControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end        
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Expression','Value','ValueStr','Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.param.(obj.ValueType);
        end
        
    end

end