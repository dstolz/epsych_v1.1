classdef CustomizationSetup < handle

    properties (SetAccess = immutable)
        parent
    end

    methods
        create(obj,parent);

        function obj = CustomizationSetup(parent)
            obj.create(parent);
            obj.parent = parent;
        end

    end

end