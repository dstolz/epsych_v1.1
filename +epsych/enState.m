classdef enState < uint8
    enumeration
        Prep    (0)
        Ready   (1)
        Preview (2)
        Run     (3)
        Pause   (4)
        Resume  (5)
        Halt    (6)
        Error   (255)
    end

    methods (Static)
        function s = list
            s = arrayfun(@char,epsych.enState(-1:5),'uni',0);
        end
    end
end