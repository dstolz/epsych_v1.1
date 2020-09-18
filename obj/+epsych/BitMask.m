classdef BitMask < uint8

    enumeration
        Undefined       (0)
        Reward          (1)
        Punish          (2)
        Hit             (3)
        Miss            (4)
        Abort           (5)
        CorrectReject   (6)
        FalseAlarm      (7)
        NoResponse      (8)
        PreResponseWindow   (9)
        ResponseWindow      (10)
        PostResponseWindow  (19)
        TrialType_0     (12)
        TrialType_1     (13)
        TrialType_2     (14)
        TrialType_3     (15)
        Response_A      (16)
        Response_B      (17)
        Response_C      (18)
        Response_D      (19)
        Response_E      (20)

    end

    
    methods (Static)
        function list
            b = epsych.BitMask(0:20);
            for i = 1:length(b)
                fprintf('% 2d\t%s\n',b(i),char(b(i)))
            end
        end
    end
end