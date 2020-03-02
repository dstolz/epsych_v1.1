classdef Phys < handle & matlab.mixin.Copyable

    properties (Abstract, SetAccess = protected)
        BitmaskGroups % define which bit will be used to group data analysis.
                      % ex: BitmaskGroups = [epsych.Bitmask.StimulusTrial epsych.Bitmask.CatchTrial]
        
        BitmaskInUse  % defines which bits are in use 
                      % ex: BitmaskInUse = [epsych.Bitmask.Hit, epsych.Bitmask.Miss, epsych.Bitmask.CorrectReject, epsych.Bitmask.FalseAlarm, epsych.Bitmask.Abort];
    end

    properties
        ParameterName  % defines which parameter(s) to analyze
                       % ex: obj.ParameterName = "StimulusFrequency"


        TrialTypeColors = lines;
    end

    properties (Dependent)
        NumTrials           (1,1) uint32
        
        ResponsesBitmask    (1,:) epsych.Bitmask
        ResponsesChar       (1,:) cell
        ResponseCodes       (1,:) uint32

        Trial_Index         (1,1) double

        TrialTypeInd        (1,:)  % 1xN structure with fields organized by trial type
        ResponseInd         (1,:)  % 1xN structure with fields organized by response code
        
        ParameterValues     (1,:)
        ParameterCount      (1,1)
        ParameterIndex      (1,1)
        ParameterFieldName  (1,:)
        ParameterData       (1,:)

        Count
        Ind
        Rate

        ValidParameters

        Subject     % subject info structure
    end

    properties (SetAccess = private)
        TRIALS
        DATA % TRIALS.DATA ... should be a value object
    end

    properties (Access = private)
        el_NewData
    end

    properties (SetAccess = immutable)
        BoxID
        CreatedOn
    end    

    methods
        function obj = Phys(BoxID,parameterName)
            global RUNTIME

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

            obj.BoxID         = BoxID;
            obj.ParameterName = parameterName;
            obj.CreatedOn     = datestr(now);

            obj.el_NewData = addlistener(RUNTIME.HELPER(obj.BoxID),'NewData',@obj.update);
        end

        function n = get.NumTrials(obj)
            n = length(obj.DATA);
        end

        
        function rc = get.ResponseCodes(obj)
            rc = [obj.DATA.ResponseCode];
        end

        function ind = get.TrialTypeInd(obj)
            
        end


        

        % Parameter -------------------------------------------------
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
            d = [obj.DATA.(obj.ParameterFieldName)];
        end

        function n = get.ParameterCount(obj)
            n = [];
            if isempty(obj.ParameterName), return; end
            v = obj.ParameterValues;
            d = obj.ParameterData;
            ind = obj.Ind;
            fn = fieldnames(ind);
            for i = 1:length(v)
                for j = 1:length(fn)
                    count.(fn{j})(i) = sum(ind.(fn{j}) & ismember(d,v{i}));
                end
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
            p = fieldnames(obj.DATA);
            p(~ismember(p,obj.TRIALS.Mwriteparams)) = [];
        end

        function d = get.DATA(obj)
            d = obj.TRIALS.DATA;
        end
        
        function s = get.Subject(obj)
            s = obj.TRIALS.Subject;
        end
        
        function i = get.Trial_Index(obj)
            i = obj.TRIALS.TrialIndex;
        end

        function r = get.ResponsesBitmask(obj)
            RC = obj.ResponseCodes;
            r(length(RC),1) = epsych.Bitmask(0);
            for i = obj.BitmaskInUse
                ind = logical(bitget(RC,i));
                if ~any(ind), continue; end
                r(ind) = i;
            end
        end
        
        function c = get.ResponsesChar(obj)
            c = cellfun(@char,num2cell(obj.ResponsesBitmask),'uni',0);
        end



        function c = get.Count(obj)
            c = structfun(@sum,obj.Ind,'uni',0);
        end

        function s = get.Ind(obj)
            TT = arrayfun(@char,obj.BitmaskInUse,'uni',0);
            for i = 1:length(TT)
                s.(TT{i}) = [obj.DATA.TrialType] == obj.BitmaskInUse(i);
            end
        end

        
    end

    methods (Access = private)
        function update(obj,src,event)
            obj.TRIALS  = event.Data;
            obj.Subject = event.Subject;
        end
    end

    methods (Static)
        function z = zscore(a)
            % bounds input to [0.01 0.99] to avoid inf values
            a  = max(min(a,0.99),0.01);
            z = sqrt(2)*erfinv(2*a-1);
        end
        
        
        function dp = dprime(hr,far)
            dp = phys.Phys.zscore(hr) - phys.Phys.zscore(far);
        end
        
        function c = bias(hr,far)
            c = -(phys.Phys.zscore(hr) + phys.Phys(far))./2;
        end
    end
end