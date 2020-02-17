classdef (Abstract) PsyPhys < handle

    properties
        BitsInUse (1,:) epsych.BitMask = 0:20;
        BitColors (:,3) double {mustBeNonnegative,mustBeLessThanOrEqual(BitColors,1)} = lines(21);
    end

    properties (Dependent)
        NumTrials      (1,1) uint16

        ResponseCodes  (1,:) uint16
        ResponseEnum   (1,:) epsych.BitMask
        ResponseChar   (1,:) cell

        TrialTypeInd (1,:)  % 1xN structure with fields organized by trial type
        ResponseInd  (1,:)  % 1xN structure with fields organized by response code

        TRIALS
        DATA % TRIALS.DATA ... should be a value object
        SUBJECT
    end

    methods

        function n = get.NumTrials(obj)
            n = length(obj.DATA);
        end

        function r = get.ResponseEnum(obj)
            RC = obj.ResponseCodes;
            r(length(RC),1) = epsych.BitMask(0);
            for i = obj.BitsInUse
                ind = logical(bitget(RC,i));
                if ~any(ind), continue; end
                r(ind) = i;
            end
        end

        function c = get.ResponseChar(obj)
            c = cellfun(@char,num2cell(obj.ResponseEnum),'uni',0);
        end
        
        function rc = get.ResponseCodes(obj)
            rc = [obj.DATA.ResponseCode];
        end

        function ind = get.TrialTypeInd(obj)
            
        end
    end

end