classdef Group < handle

    properties
        Items (1,:) parameter.Parameter
    end

    properties (Dependent)
        Compiled
        N
        Names
        
        PairNames
        
        isPaired
    end
    
    methods
        function obj = Group(Items)
            if nargin == 0, return; end
            
            obj.Items = Items;
            
            obj.test_unique_names;
        end
        
        
        function n = get.N(obj)
            n = length(obj.Items);
        end
        
        function n = get.Names(obj)
            n = {obj.Items.Name};
        end
        
        function n = get.PairNames(obj)
            n = {obj.Items.PairName};
        end
        
        function tf = get.isPaired(obj)
            tf = ~cellfun(@isempty,obj.PairNames);
        end
        
        function c = get.Compiled(obj)
            c = {};
            pnames  = obj.PairNames;
            upnames = unique(pnames);
            ok = arrayfun(@(a) test_pair_length(obj,a),upnames);
            if ~all(ok)
                fprintf(2,'epsych.Group:get.Compiled:InvalidPairLength\n%s\n', ...
                    'Paired Items must evaluate to the same lengths')
                return
            end
            
            % how many permutations do we have?
            x = [obj.Items(arrayfun(@(a) find(ismember(pnames,a),1),upnames)).N];
            nP = prod(x);
            nNP = prod([obj.Items(~obj.isPaired).N]);
            
            nT = nP*nNP;
            
            for i = 1:length(upnames)
                ind = ismember(pnames,upnames{i});
                
            end
            
            
        end
        
        function ok = test_pair_length(obj,idx)
            ind = ismember(obj.PairNames,idx);
            n = [obj.Items(ind).N];
            ok = all(n == n(1));
        end
        
        function p = getPair(obj,idx)
            pn = {obj.Items.PairName};
            ind = ismember(pn,idx);
            p = obj.Items(ind);
        end
    end
    
    methods (Access = private)
        function test_unique_names(obj)
            tf = length(unique(obj.Names)) == obj.N;
            assert(tf,'epsych.Group:test_unique_names:NonUniqueNames', ...
                'All Parameter names in the Group must be unique');
        end
    end

end