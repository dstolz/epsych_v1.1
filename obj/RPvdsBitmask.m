classdef RPvdsBitmask < handle
    
    properties
        Bank
        Params
    end
    
    properties (Dependent)
        Bitmask
        BitStates
        N
    end
    
    properties (SetAccess = private)
        BankTag
        Labels
        Bits
    end
    
    properties (SetAccess = immutable)
        Runtime
        TDTActiveX
    end
    
    methods
        function obj = RPvdsBitmask(Runtime,TDTActiveX,bank)
            obj.Runtime = Runtime;
            obj.TDTActiveX = TDTActiveX;
            
            obj.Bank = bank; 
        end
        
        function b = get.Bitmask(obj)
            b = nan;
            
            if isempty(obj.BankTag), return; end
            
            b = obj.TDTActiveX.GetTagVal(obj.BankTag);
        end
        
        function v = get.BitStates(obj)
            v = {};
            
            bm = obj.Bitmask;
            if isnan(bm), return; end
            
            v = obj.Labels(:);
            v(:,2) = num2cell(bitget(obj.Bitmask,obj.Bits+1));
        end
        
        function set.Bank(obj,bank)
            obj.Bank = bank;
            obj.update;
        end
        
        function n = get.N(obj)
            n = numel(obj.Bits);
        end
    end
    
    methods (Access = private)
        function update(obj)
            obj.BankTag = sprintf('~BMid-%s',obj.Bank);

            p = obj.Runtime.TDT.devinfo.tags;
            b = sprintf('~BM-%s',obj.Bank);
            n = length(b);
            obj.Params = p(startsWith(p,b));
            obj.Params = cellfun(@(a) a(n+1:end),obj.Params,'uni',0);
            
            obj.Labels = cell(size(obj.Params));
            obj.Bits   = zeros(size(obj.Params));
            for i = 1:length(obj.Params)
                hi = find(obj.Params{i} == '#',1);                
                obj.Bits(i)   = str2double(obj.Params{i}(hi+1));
                
                ci = find(obj.Params{i} == '^',1);
                obj.Labels{i} = obj.Params{i}(ci+1:end);
            end
        end
    end
end