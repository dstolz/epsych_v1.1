classdef UIPopupmenu < epsych.param.UIControl
    
    properties         
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'popupmenu';
    end

    methods
        function obj = UIPopupmenu(varargin)
            obj = obj@epsych.param.UIControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.epsych.param.(obj.ValueType);
        end
    end

end