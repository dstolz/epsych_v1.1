classdef Metrics < handle & matlab.mixin.Copyable

    properties (SetAccess = protected) % Abstract

        TrialTypes = [epsych.Bitmask.TrialType_0, ...
                      epsych.Bitmask.TrialType_1, ...
                      epsych.Bitmask.TrialType_2, ...
                      epsych.Bitmask.TrialType_3];
                    
        BitsInUse  = [epsych.Bitmask.Hit, ...
                      epsych.Bitmask.Miss, ...
                      epsych.Bitmask.Response_A, ...
                      epsych.Bitmask.Response_B, ...
                      epsych.Bitmask.NoResponse, ...
                      epsych.Bitmask.Abort];
                
        isOnline    (1,1) logical = false;
    end

    properties
        ParameterName  % defines which parameter(s) to analyze
                       % ex: obj.ParameterName = "StimulusFrequency"

        PerformanceColors = lines;
    end

    properties (Dependent)
        NumTrials           (1,1) uint16
        
        ResponsesBitmask    (1,:) epsych.Bitmask
        ResponsesChar       (1,:) cell
        ResponseCode        (1,:) uint16

        TrialIndex         (1,1) double

        TrialTypeCount

        ResponseCodeBits
        

        ValidParameters
    end

    properties (SetAccess = private)
        TRIALS
        DATA        % TRIALS.DATA
        Subject     % subject info structure
        
        BitmaskInUseChar
        TrialTypesChar
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

    methods (Abstract)
        P = compute_performance(obj);
    end

    methods
        function obj = Metrics(BoxID)
            global RUNTIME

            obj.isOnline = ~isempty(RUNTIME);

            d = dbstack;
            obj.Paradigm = d(2).file(1:end-2);
            if nargin == 0 || isempty(BoxID), BoxID = 1; end
                       
            obj.BoxID     = BoxID;
            % obj.ParameterName = parameterName;
            obj.CreatedOn = datestr(now);

            if obj.isOnline
                % Note that BoxID shouldn't be changed for this object after creation (immutable)
                obj.el_NewData = addlistener(RUNTIME.HELPER(obj.BoxID),'NewData',@obj.update);
            end
            
        end

        function set.BitsInUse(obj,biu)
            obj.BitsInUse = biu;
            obj.BitmaskInUseChar = arrayfun(@char,obj.BitsInUse,'uni',0);
        end

        function set.TrialTypes(obj,bg)
            obj.TrialTypes = bg;
            obj.TrialTypesChar = arrayfun(@char,obj.TrialTypes,'uni',0);
        end

        function n = get.NumTrials(obj)
            n = length(obj.DATA);
        end

        
        function rc = get.ResponseCode(obj)
            rc = [obj.DATA.ResponseCode];
        end


        

        % Parameter -------------------------------------------------
        function p = get.ValidParameters(obj)
            if isempty(obj.DATA), p = 'NEED DATA!'; return; end
            p = fieldnames(obj.DATA);
            p(~ismember(p,obj.TRIALS.Mwriteparams)) = [];
        end

        
        function i = get.TrialIndex(obj)
            i = obj.TRIALS.TrialIndex;
        end

        function r = get.ResponsesBitmask(obj)
            RC = obj.ResponseCode;
            r(length(RC),1) = epsych.Bitmask(0);
            for i = obj.BitsInUse
                ind = logical(bitget(RC,i));
                if ~any(ind), continue; end
                r(ind) = i;
            end
        end
        
        function c = get.ResponsesChar(obj)
            c = cellfun(@char,num2cell(obj.ResponsesBitmask),'uni',0);
        end

        function s = get.ResponseCodeBits(obj)
            RC = obj.ResponseCode;

            c = obj.BitmaskInUseChar;
            for i = 1:length(c)
                s.(c{i}) = bitget(RC,obj.BitsInUse(i),'uint16');
            end

            c = obj.TrialTypesChar;
            for i = 1:length(c)
                s.(c{i}) = bitget(RC,obj.TrialTypes(i),'uint16');
            end
            
            s = structfun(@logical,s,'uni',0);
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
            Ad = normcdf(metrics.Metrics.dprime_2afc(hr,far,N));
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

        



        
        
        function c = decode_ResponseCode(ResponseCode)
            idx = 1:16;
            d = arrayfun(@(a) bitget(a,idx,'uint16'),ResponseCode,'uni',0);
            c = [d{:}];
        end
    end
end