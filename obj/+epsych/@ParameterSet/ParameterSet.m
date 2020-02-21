classdef ParameterSet

    properties
        Parameters (1,:) epsych.Parameter
    end

    properties (Dependent)
        Compiled
        N
        Names
        PairNames
        PairIndex
    end
    
    methods
        function obj = ParameterSet(Parameters)
            if nargin == 0, return; end
            
            obj.Parameters = Parameters;
        end
        
        function n = get.N(obj)
            n = length(obj.Parameters);
        end
        
        function n = get.Names(obj)
            n = {obj.Parameters.Name};
        end
        
        function n = get.PairNames(obj)
            n = unique({obj.Parameters.PairName});
        end
        
        function pidx = get.PairIndex(obj)
            pidx = nan;
            pn  = {obj.Parameters.PairName};
            pn(cellfun(@isempty,pn)) = [];
            if isempty(pn), return; end
            upn = unique(pn);
            pidx = nan(1,obj.N);
            k = 1;
            for i = 1:obj.N
                ind = ismember(pn,upn{i});
                if ~any(ind), continue; end
                pidx(ind) = k;
                k = k + 1;
            end
        end
        
        function p = getPairs(obj,idx)
            p = [];
            pidx = obj.PairIndex;
            if isnan(pidx), return; end
            if nargin == 0 % return all pairs
                for i = pidx
                    p{1,i} = obj.getPairs(i);
                end
                return
            end
            
            p = obj.Parameters(idx == pidx);
        end
        
        function c = get.Compiled(obj)
            ps = obj.getPairs;
            pn = cellfun(@(a) a.N,ps);
            
        end
        
    end

end