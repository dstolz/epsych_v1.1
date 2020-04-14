classdef State < int8
    enumeration
        Error   (-1)
        Prep    (0)
        Run     (1)
        Preview (2)
        Pause   (3)
        Resume  (4)
        Halt    (5)
    end

    methods (Static)
        function s = list
            s = arrayfun(@char,epsych.State(-1:5),'uni',0);
        end
    end
end