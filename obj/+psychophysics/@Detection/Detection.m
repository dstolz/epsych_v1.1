classdef Detection < handle

% future Dan: update to make use of enumerated types ep.TrialType and ep.BitMask

    properties
        Hit_Bit     (1,1) uint8 = 3;
        Miss_Bit    (1,1) uint8 = 4;
        FA_Bit      (1,1) uint8 = 6;
        CR_Bit      (1,1) uint8 = 7;

        Go_TrialType     (1,1) double = 0;
        NoGo_TrialType   (1,1) double = 1;

        ParameterName   (1,:) char
        ParameterIDs    (1,:) uint8

        BoxID      (1,1) uint8 = 1;
    end

    properties (SetAccess = private)
        NumTrials     (1,1) uint16 = 0;
        
        Go_Count        (1,1) uint16 = 0;
        NoGo_Count      (1,1) uint16 = 0;

        ResponseCodes   (1,:) uint16

        ValidParameters (1,:) cell

        Hit_Ind     (1,:) logical
        Miss_Ind    (1,:) logical
        FA_Ind      (1,:) logical
        CR_Ind      (1,:) logical

        Hit_Count   (1,:) double
        Miss_Count  (1,:) double
        FA_Count    (1,:) double
        CR_Count    (1,:) double
        
        Trial_Count (1,:) double

        Hit_Rate    (1,:) double
        Miss_Rate   (1,:) double
        FA_Rate     (1,:) double
        CR_Rate     (1,:) double

        DPrime      (1,:) double
        Bias        (1,:) double
        
        HR_FA_Diff  (1,:) double
        
        PlotTools   (1,1) % PlotTools
        
        Trial_Index (1,1) double
    end
    

    properties (SetAccess = private, Dependent)
        ParameterValues     (1,:)
        ParameterCount      (1,1)
        ParameterIndex      (1,1)
        ParameterFieldName  (1,:)
        ParameterData       (1,:)
    end

    properties (Access = private)
        TRIALS
        listener_NewData
    end

    
    events (ListenAccess = 'public', NotifyAccess = 'protected')
        ParameterUpdate
    end
    
    
    methods        
        function obj = Detection(BoxID,parameterName)
            
            if nargin < 1 || isempty(BoxID), BoxID = 1; end
            if nargin < 2 || isempty(parameterName)
                % choose most variable parameter
                p = obj.ValidParameters;
                T = obj.TRIALS;
                for i = 1:length(p)
                    ind = ismember(T.Mwriteparams,p{i});
                    if ~any(ind), continue; end
                    a = T.trials(:,ind);
                    if isnumeric(a{1})
                        v(i) = length(unique([a{:}]));
                    elseif ischar(a{1})
                        v(i) = length(unique(a));
                    elseif isstruct(a{1})
                        v(i) = length(cellfun(@(x) x.file,a,'uni',0));
                    end
                end
                [~,m] = max(v);
                parameterName = p{m};
            end

            obj.BoxID = BoxID;
            obj.ParameterName = parameterName;
            
        end

        
        
        function link_with_helper(obj,src)
            obj.listener_NewData = addlistener(src,'NewData',@obj.update_plot);
        end
        
        function update_plot(obj,src,event)
            if nargin == 3 && isfield(event,'BoxID') && event.BoxID ~= obj.BoxID
                return;
            else
                event = [];
            end
            if ~isempty(obj.PlotTools.AxesH) && isvalid(obj.PlotTools.AxesH)
                obj.PlotTools.update_plot(obj,event);
            end
        end
        

        % Ind ------------------------------------------------------
        function r = get.Hit_Ind(obj)
            r = bitget(obj.ResponseCodes,obj.Hit_Bit);
            r = logical(r);
        end

        function r = get.Miss_Ind(obj)
            r = bitget(obj.ResponseCodes,obj.Miss_Bit);
            r = logical(r);
        end

        function r = get.FA_Ind(obj)
            r = bitget(obj.ResponseCodes,obj.FA_Bit);
            r = logical(r);
        end

        function r = get.CR_Ind(obj)
            r = bitget(obj.ResponseCodes,obj.CR_Bit);
            r = logical(r);
        end


    

        % Count -----------------------------------------------------
        function r = get.Go_Count(obj)
            r = sum([obj.TRIALS.DATA.TrialType] == obj.Go_TrialType);
        end

        function r = get.NoGo_Count(obj)
            r = sum([obj.TRIALS.DATA.TrialType] == obj.NoGo_TrialType);
        end
        
        function n = get.Trial_Count(obj)
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

        function dp = get.DPrime(obj)
            dp = obj.zscore(obj.Hit_Rate) - obj.zscore(obj.FA_Rate);
        end

        function c = get.Bias(obj)
            c = -(obj.zscore(obj.Hit_Rate) + obj.zscore(obj.FA_Rate))./2;
        end
        
        function rc = get.ResponseCodes(obj)
            rc = [obj.TRIALS.DATA.ResponseCode];
        end

        function n = get.NumTrials(obj)
            n = length(obj.TRIALS.DATA);
        end


        % Parameter -------------------------------------------------
        function set.ParameterName(obj,name)
            ind = ismember(obj.ValidParameters,name);
            assert(any(ind),'ep_Psychophysics_Detection:set.ParameterName','Invalid parameter name: %s',name);
            obj.ParameterName = name;
            
            obj.notify('ParameterUpdate');
        end

        function v = get.ParameterValues(obj)
            v = [];
            if isempty(obj.ParameterName), return; end
            a = obj.TRIALS.trials(:,obj.ParameterIndex);
            if isnumeric(a{1})
                v = unique([a{:}]);
            elseif ischar(a{1})
                v = unique(a);
            elseif isstruct(a{1})
                v = cellfun(@(x) x.file,a,'uni',0);
            end
        end

        function d = get.ParameterData(obj)
            d = [obj.TRIALS.DATA.(obj.ParameterFieldName)];
        end

        function n = get.ParameterCount(obj)
            n = [];
            if isempty(obj.ParameterName), return; end
            v = obj.ParameterValues;
            d = obj.ParameterData;
            for i = 1:length(v)
                n(i) = sum(obj.Hit_Ind & ismember(d,v{i}));
            end
        end

        function i = get.ParameterIndex(obj)
            i = [];
            if isempty(obj.ParameterName), return; end
            i = find(ismember(obj.TRIALS.Mwriteparams,obj.ParameterName));
        end

        function n = get.ParameterFieldName(obj)
            n = [];
            if isempty(obj.ParameterName), return; end
            n = obj.TRIALS.Mwriteparams{obj.ParameterIndex};
        end

        function p = get.ValidParameters(obj)
            p = fieldnames(obj.TRIALS.DATA);
            p(~ismember(p,obj.TRIALS.Mwriteparams)) = [];
        end
        
        function t = get.TRIALS(obj)
            global RUNTIME
            t = RUNTIME.TRIALS(obj.BoxID);
        end
        
        function i = get.Trial_Index(obj)
            i = obj.TRIALS.TrialIndex;
        end
        
        
        function create_plot(obj,ax)
            if nargin < 2 || isempty(ax), ax = gca; end
            obj.PlotTools = psychophysics.PlotTools(obj,ax);
            obj.PlotTools.update_plot(obj);
        end
    end

    methods (Static)
        function z = zscore(a)
            % bounds input to [0.01 0.99] to avoid inf values
            a  = max(min(a,0.99),0.01);
            z = sqrt(2)*erfinv(2*a-1);
        end
    end
end