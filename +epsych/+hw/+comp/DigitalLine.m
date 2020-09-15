classdef DigitalLine < handle
     
    properties (SetObservable,AbortSet)
        Alias       (1,1) string  = "DigitalLine";
        Label       (1,1) string  = "DigitalLine";
        isOutput    (1,1) logical = false;
        State       (1,1) logical
    end
    
    properties
        StateStr
    end

    properties (Hidden)
        hIndicator
    end
    
    methods
        function obj = DigitalLine(isOutput,Label,Alias)
            if nargin > 0, obj.isOutput = isOutput; end
            if nargin > 1, obj.Label    = Label;    end
            if nargin > 2, obj.Alias = Alias, else obj.Alias = obj.Label; end
        end
                
        function set.State(obj,s)
            obj.State = logical(s);
        end

        function s = get.StateStr(obj)
            if obj.State
                s = 'on';
            else
                s = 'off';
            end
        end
        
        function set.StateStr(obj,s)            
            obj.State = strcmpi(s,'on');
        end

    end
end