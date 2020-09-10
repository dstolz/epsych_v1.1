classdef Project < handle
    
    properties
        
    end
    
    properties (SetAccess = immutable)
        CreatedOn
    end
    
    methods
        function obj = Project
            obj.CreatedOn = datestr(now);
        end
    end
end