classdef Helper < handle
    

    properties

    end

    events (ListenAccess = 'public', NotifyAccess = 'public')
        NewData
    end

    methods
        
        
    end
    
    methods (Static)
        function tf = valid_psych_obj(obj)
            tf = isobject(obj);
            if ~tf, return; end
            c = class(obj);
            tf = isequal(c(1:find(c=='.')-1),'psychophysics');
        end

    end

end