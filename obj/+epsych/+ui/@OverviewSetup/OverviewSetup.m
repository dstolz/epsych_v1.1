classdef OverviewSetup < handle

    properties
         
    end

    % Properties that correspond to obj components
    properties (Access = protected)
                
    end
    
    properties (SetAccess = immutable)
        parent
    end

    methods
        create(obj,parent);
        
        % Constructor
        function obj = OverviewSetup(parent)
            narginchk(1,1)
            
            create(obj,parent)
            
            obj.parent = parent;
            
            if nargout == 0, clear obj; end
        end

        function delete(obj)
            delete(obj.parent)
        end
        
    end
    
end