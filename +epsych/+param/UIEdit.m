classdef uiEdit < epsych.param.uiControl
    
    properties 
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'edit';
    end

    methods
        function obj = uiEdit(varargin)
            obj = obj@epsych.param.uiControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end        
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Expression','Value','ValueStr','Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.param.(obj.ValueType);
        end
        
    end

end