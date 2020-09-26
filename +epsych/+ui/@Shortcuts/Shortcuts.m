classdef Shortcuts < handle

    properties (SetAccess = private)
        parent
    end

    methods
        create(obj,parent);
        function obj = Shortcuts(parent)
            if nargin == 0, parent = []; end
            
            obj.create(parent);
        end

        function launch(obj,hObj,event)
            eval(hObj.UserData);
        end
    end
end