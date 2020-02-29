classdef Detection < phys.Phys
        
    properties
        ParameterName   (1,:) char
        ParameterIDs    (1,:) uint8
    end
    
    
    properties (SetAccess = protected)
        BitmaskInUse phys.Bitmask = [phys.Bitmask.Hit, phys.Bitmask.Miss, phys.Bitmask.CorrectReject, phys.Bitmask.FalseAlarm, phys.Bitmask.Abort];
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

            obj.TrialTypeColors = [.8 1 .8; 1 .7 .7; .7 .9 1; 1 .7 1; 1 1 .4]; % [Hit Miss CR FA Abort]

        end
        
        
        
        
        % Ind ------------------------------------------------------
        function r = get.Hit_Ind(obj)
            r = bitget(obj.ResponseCodes,epsych.BitMask.Hit);
            r = logical(r);
        end
        
        function r = get.Miss_Ind(obj)
            r = bitget(obj.ResponseCodes,epsych.BitMask.Miss);
            r = logical(r);
        end
        
        function r = get.FA_Ind(obj)
            r = bitget(obj.ResponseCodes,epsych.BitMask.FalseAlarm);
            r = logical(r);
        end
        
        function r = get.CR_Ind(obj)
            r = bitget(obj.ResponseCodes,epsych.BitMask.CorrectReject);
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
            ind = obj.Ind.Go;
            for i =1:length(v)
                n(i) = sum(ind & d == v(i));
            end
        end
        
        function n = get.NoGo_Count(obj)
            v = obj.ParameterValues;
            d = obj.ParameterData;
            ind = obj.Ind.NoGo;
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