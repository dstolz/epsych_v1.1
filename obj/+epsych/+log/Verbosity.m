classdef Verbosity < int8

    enumeration
        PrintOnly       (-2)
        ScreenOnly      (-1)
        Error           (0)
        Critical        (1)
        Important       (2)
        Verbose         (3)
        Debug           (4)
        Insanity        (5)
    end

    
    methods (Static)
        function s = list
            s = arrayfun(@char,epsych.log.Verbosity(-2:5),'uni',0);
        end
        
    end
end