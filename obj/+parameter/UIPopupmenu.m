classdef UIPopupmenu < parameter.UIControl
    
    properties         
        ValueType = 'ValuesStr';
    end
    
    properties (Constant)
        Style = 'popupmenu';
    end

    methods
        function obj = UIPopupmenu(varargin)
            obj = obj@parameter.UIControl(varargin{:});
            obj.ValueType = obj.ValueType;
        end
        
        function set.ValueType(obj,type)
            mustBeMember(type,{'Values','ValuesStr'})
            obj.ValueType = type;
            obj.hControl.String = obj.Parameter.(obj.ValueType);
        end
    end

end