classdef Group < handle

    properties
        Parameters (1,:) epsych.param.Parameter
    end

    properties (Dependent)
        Compiled
        N
        Names
        
        PairNames
        
        isPaired
        isRange
    end
    
    methods
        function obj = Group(Parameters)
            if nargin == 0, return; end
            
            obj.Parameters = Parameters;
            
            obj.test_unique_names;
        end
        
        
        function n = get.N(obj)
            n = length(obj.Parameters);
        end
        
        function n = get.Names(obj)
            n = {obj.Parameters.Name};
        end
        
        function n = get.PairNames(obj)
            n = {obj.Parameters.PairName};
        end
        
        function tf = get.isPaired(obj)
            tf = [obj.Parameters.isPaired];
        end
        
        function tf = get.isRange(obj)
            tf = [obj.Parameters.isRange];
        end
        
        function s = get.Compiled(obj)
            
            for i = 1:obj.N
                [s,f] = obj.add_trial(obj.Parameters(i));
            end
        end
        
        function ok = test_pair_length(obj,idx)
            ind = ismember(obj.PairNames,idx);
            n = [obj.Parameters(ind).N];
            ok = all(n == n(1));
        end
        
        function p = getPair(obj,idx)
            pn = {obj.Parameters.PairName};
            ind = ismember(pn,idx);
            p = obj.Parameters(ind);
        end
    end % methods
    
    methods (Access = private)
        function test_unique_names(obj)
            tf = length(unique(obj.Names)) == obj.N;
            assert(tf,'epsych.Group:test_unique_names:NonUniqueNames', ...
                'All Parameter names in the Group must be unique');
        end
    end % methods (Access = private)

    methods (Static)
        [schedule,fail] = add_trial(schedule,parameter,varargin);
    end % methods (Static)

end