classdef State < int8
    enumeration
        Error   (-1)
        Prep    (0)
        Run     (1)
        Preview (2)
        Pause   (3)
        Halt    (4)
    end
    
end