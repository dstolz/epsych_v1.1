classdef (Hidden) StimPlay < handle
    
    
    properties (AbortSet,SetObservable)
        StimObj % stimgen objects
        ListIdx (1,1) double {mustBeInteger} = 0;
        Reps    (1,1) double {mustBeInteger} = 20;
        ISI     (1,2) double {mustBePositive,mustBeFinite} = 1;
        
        Name    (1,1) string
        DisplayName (1,1) string
        
    end
    
    properties (Dependent)
        Type
    end
    
    methods
        
        function t = get.Type(obj)
            t = class(obj.StimObj);
            t(1:find(t=='.')) = [];
        end
        
        function n = get.DisplayName(obj)
            if isempty(obj.DisplayName) || obj.DisplayName == ""
                isi = obj.ISI;
                if all(isi==isi(1))
                    isi(2) = [];
                end
                isistr = mat2str(isi);
                n = string(sprintf('%s (%s) x%d, isi = %s sec', ...
                    obj.Name,obj.Type,obj.Reps,isistr));
            else
                n = obj.DisplayName;
            end
        end
    end
end