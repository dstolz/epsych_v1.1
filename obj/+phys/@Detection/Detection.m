classdef Detection < phys.Phys
        

    properties (SetAccess = protected) % define abstract properties inherited from phys.Phys
        TrialTypes = [epsych.Bitmask.StimulusTrial, epsych.Bitmask.CatchTrial];
        BitmaskInUse  = [epsych.Bitmask.Hit, epsych.Bitmask.Miss, epsych.Bitmask.CorrectReject, epsych.Bitmask.FalseAlarm, epsych.Bitmask.Abort];
    end

    
    properties (SetAccess = private)
        Go_Ind       (1,:) logical
        NoGo_Ind     (1,:) logical

        Go_Count     (1,1) uint16 = 0;
        NoGo_Count   (1,1) uint16 = 0;
        
        Hit_Ind     (1,:) logical
        Miss_Ind    (1,:) logical
        FA_Ind      (1,:) logical
        CR_Ind      (1,:) logical
        
        Hit_Count   (1,:) double
        Miss_Count  (1,:) double
        FA_Count    (1,:) double
        CR_Count    (1,:) double
        
        TrialCount (1,:) double
        
        Hit_Rate    (1,:) double
        Miss_Rate   (1,:) double
        FA_Rate     (1,:) double
        CR_Rate     (1,:) double
        
        DPrime      (1,:) double
        Bias        (1,:) double
        
        HR_FA_Diff  (1,:) double
    end
    
    
    methods
        function obj = Detection(BoxID,parameterName)
            if nargin < 1 || isempty(BoxID), BoxID = 1; end
            if nargin < 2, parameterName = []; end
            obj = obj@phys.Phys(BoxID,parameterName);

            obj.PerformanceColors = [.8 1 .8; 1 .7 .7; .7 .9 1; 1 .7 1; 1 1 .4]; % [Hit Miss CR FA Abort]

        end
        
        
        
        
        % ResponseCodeBits ------------------------------------------------------
        function r = get.Hit_Ind(obj)
            r = bitget(obj.ResponseCodes,epsych.Bitmask.Hit);
            r = logical(r);
        end
        
        function r = get.Miss_Ind(obj)
            r = bitget(obj.ResponseCodes,epsych.Bitmask.Miss);
            r = logical(r);
        end
        
        function r = get.FA_Ind(obj)
            r = bitget(obj.ResponseCodes,epsych.Bitmask.FalseAlarm);
            r = logical(r);
        end
        
        function r = get.CR_Ind(obj)
            r = bitget(obj.ResponseCodes,epsych.Bitmask.CorrectReject);
            r = logical(r);
        end
        
        function i = get.Go_Ind(obj)
            i = [obj.DATA.TrialType] == phys.Bitmask.Go;
        end
        
        function i = get.NoGo_Ind(obj)
            i = [obj.DATA.TrialType] == phys.Bitmask.NoGO;
        end
        
        % Count -----------------------------------------------------
        function n = get.Go_Count(obj)
            v = obj.ParameterValues;
            d = obj.ParameterData;
            ind = obj.ResponseCodeBits.Go;
            for i =1:length(v)
                n(i) = sum(ind & d == v(i));
            end
        end
        
        function n = get.NoGo_Count(obj)
            v = obj.ParameterValues;
            d = obj.ParameterData;
            ind = obj.ResponseCodeBits.NoGo;
            for i =1:length(v)
                n(i) = sum(ind & d == v(i));
            end
        end
        
        function n = get.TrialCount(obj)
            v = obj.ParameterValues;
            d = obj.ParameterData;
            for i =1:length(v)
                n(i) = sum(d == v(i));
            end
        end
        
        function n = get.Hit_Count(obj)
            v = obj.ParameterValues;
            d = obj.ParameterData;
            for i = 1:length(v)
                n(i) = sum(obj.Hit_Ind & d == v(i));
            end
        end
        
        function n = get.Miss_Count(obj)
            v = obj.ParameterValues;
            d = obj.ParameterData;
            for i = 1:length(v)
                n(i) = sum(obj.Miss_Ind & d == v(i));
            end
        end
        
        function n = get.FA_Count(obj)
            v = obj.ParameterValues;
            d = obj.ParameterData;
            for i = 1:length(v)
                n(i) = sum(obj.FA_Ind & d == v(i));
            end
        end
        function n = get.CR_Count(obj)
            v = obj.ParameterValues;
            d = obj.ParameterData;
            for i = 1:length(v)
                n(i) = sum(obj.CR_Ind & d == v(i));
            end
        end
        
        
        
        % Rate ----------------------------------------------------
        function r = get.Hit_Rate(obj)
            r = obj.Hit_Count ./ obj.Go_Count;
        end
        
        function r = get.Miss_Rate(obj)
            r = 1 - obj.Hit_Rate;
        end
        
        function r = get.CR_Rate(obj)
            r = obj.CR_Count ./ obj.NoGo_Count;
        end
        
        function r = get.FA_Rate(obj)
            r = 1 - obj.CR_Rate;
        end
        
        
        function c = get.Bias(obj)
            c = -(obj.zscore(obj.Hit_Rate) + obj.zscore(obj.FA_Rate))./2;
        end
        
    end
    
end