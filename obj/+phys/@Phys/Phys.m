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

        TrialIndex         (1,1) double

        TrialTypeInd        (1,:)  % 1xN structure with fields organized by trial type
        ResponseInd         (1,:)  % 1xN structure with fields organized by response code
        
        TrialTypeCount

        ParameterValues     (1,:)
        ParameterCount      (1,1)
        ParameterIndex      (1,1)
        ParameterFieldName  (1,:)
        ParameterData       (1,:)

        Count
        Ind
        Rate

        ValidParameters
    end

    properties (SetAccess = private)
        TRIALS
        DATA        % TRIALS.DATA
        Subject     % subject info structure
    end

    properties (Access = private)
        el_NewData
    end

    properties (SetAccess = immutable)
        BoxID
        CreatedOn
        Paradigm
    end    

    events
        NewPhysData
    end

    methods
        function obj = Phys(parameterName,BoxID)
            d = dbstack;
            obj.Paradigm = d(2).file(1:end-2);
            
            if nargin < 1 || isempty(parameterName)
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

            if nargin < 2 || isempty(BoxID), BoxID = 1; end
                
            obj.BoxID         = BoxID;
            obj.ParameterName = parameterName;
            obj.CreatedOn     = datestr(now);

            global RUNTIME
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

        function c = get.TrialTypeCount(obj)

        end

        

        % Parameter -------------------------------------------------
        function v = get.ParameterValues(obj)
            v = [];
            if isempty(obj.ParameterName) || isempty(obj.TRIALS), return; end
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

        function count = get.ParameterCount(obj)
            count = [];
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

        
        function i = get.TrialIndex(obj)
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

        function r = get.Rate(obj)
            
        end

        function c = get.Count(obj)
            c = structfun(@sum,obj.Ind,'uni',0);
        end

        function s = get.Ind(obj)
            % decode all 
            idx = 1:16;
            C = arrayfun(@(a) bitget(a,idx,'uint16'),obj.DATA.ResponseCode,'uni',0);
            C = [C{:}];
           
            TT = arrayfun(@char,obj.BitmaskGroups,'uni',0);
            for i = 1:length(TT)
%                 s.(TT{i}) = 
            end
        end

        
    end

    
    
    
    
    methods (Access = private)
        function update(obj,src,event)
            obj.TRIALS  = event.Data;
            obj.DATA    = event.Data.DATA;
            obj.Subject = event.Subject;

            notify(obj,'NewPhysData');
        end
    end

    
    
    
    
    
    
    
    
    
    
    
    methods (Static)
        
        function dp = dprime(hr,far,N)
            % Stanislaw & Todorov, 1999
            if nargin == 3 && ~isempty(N) % Macmillan and Kaplan, 1985 bounds
                n = 1./(2.*N);
                hr(hr == 0)  = n;  hr(hr == 1)   = 1 - n;
                far(far ==0) = n;  far(far == 1) = 1 - n;
            else % artificial bounds
                hr  = max(min(hr,0.99),0.01);
                far = max(min(far,0.99),0.01);
            end
            dp = norminv(hr,0,1) - norminv(far,0,1);
        end

        function Ad = dprime_2afc(hr,far,N)
            % dprime 2AFC (also yes/no) correction
            % Stanislaw & Todorov, 1999
            if nargin == 3 && ~isempty(N) % Macmillan and Kaplan, 1985 bounds
                n = 1./(2.*N);
                hr(hr == 0)  = n;  hr(hr == 1)   = 1 - n;
                far(far ==0) = n;  far(far == 1) = 1 - n;
            else % artificial bounds
                hr  = max(min(hr,0.99),0.01);
                far = max(min(far,0.99),0.01);
            end
            Ad = (norminv(hr,0,1) - norminv(far,0,1))./sqrt(2);
        end

        function Ad = adprime(hr,far,N)
            % area under ROC
            % Stanislaw & Todorov, 1999
            if nargin < 3, N = []; end
            Ad = normcdf(phys.Phys.dprime_2afc(hr,far,N));
        end

        function Ap = aprime(hr,far)
            % non-parametric d-prime
            % Stanislaw & Todorov, 1999
            d = hr-far;
            Ap = .5 + sign(d) .* ((d.^2 + abs(d))./(4.*max(hr,far) - 4.*hr.*far));
        end

        function beta = bias_lnbeta(hr,far,N)
            % Stanislaw & Todorov, 1999
            % Note that beta returned from this function is the natural logarithm of beta
            if nargin == 3 && ~isempty(N) % Macmillan and Kaplan, 1985 bounds
                n = 1./(2.*N);
                hr(hr == 0)  = n;  hr(hr == 1)   = 1 - n;
                far(far ==0) = n;  far(far == 1) = 1 - n;
            else % artificial bounds
                hr  = max(min(hr,0.99),0.01);
                far = max(min(far,0.99),0.01);
            end
            beta = exp((norminv(far).^2 - norminv(hr).^2)./2);
        end

        function c = bias_c(hr,far,N)
            % Stanislaw & Todorov, 1999
            if nargin == 3 && ~isempty(N) % Macmillan and Kaplan, 1985 bounds
                n = 1./(2.*N);
                hr(hr == 0)  = n;  hr(hr == 1)   = 1 - n;
                far(far ==0) = n;  far(far == 1) = 1 - n;
            else % artificial bounds
                hr  = max(min(hr,0.99),0.01);
                far = max(min(far,0.99),0.01);
            end
            c = -(norminv(hr) + norminv(far)) ./ 2;
        end

        
    end
end