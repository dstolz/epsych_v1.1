classdef (Hidden) StimPlay < handle
    
    
    properties
        StimObj % stimgen objects
        ListIdx (1,1) double {mustBeInteger} = 0;
        Reps    (1,1) double {mustBeInteger} = 20;
        ISI     (1,2) double {mustBePositive,mustBeFinite} = 1;
        
        Name    (1,1) string
        DisplayName (1,1) string
    end
    
    methods
        function n = get.DisplayName(obj)
            if isempty(obj.DisplayName) || obj.DisplayName == ""
                n = string(sprintf('%s x%d isi %g',obj.Name,obj.Reps,obj.ISI));
            else
                n = obj.DisplayName;
            end
        end
    end
end