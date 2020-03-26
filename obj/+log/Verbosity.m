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

end