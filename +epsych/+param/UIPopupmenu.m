classdef uiPopupmenu < epsych.param.uiControl
    
    properties         
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'popupmenu';
    end

    methods
        function obj = uiPopupmenu(varargin)
            obj = obj@epsych.param.uiControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.param.(obj.ValueType);
        end
    end

end