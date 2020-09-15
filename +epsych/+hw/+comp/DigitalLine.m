classdef DigitalLine < handle
     
    properties (SetObservable,AbortSet)
        Index       (1,1) uint8
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
        function obj = DigitalLine(Index,isOutput,Label)
            if nargin > 0, obj.Index    = Index;    end
            if nargin > 1, obj.isOutput = isOutput; end
            if nargin > 2, obj.Label    = Label;    end
            
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