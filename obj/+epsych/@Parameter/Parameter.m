classdef Parameter < handle & matlab.mixin.Copyable & matlab.mixin.SetGet
    % P = epsych.Parameter('Property','Value',...)

    properties
        Expression      (1,:) 
        Index           (1,1) double {mustBeInteger,mustBePositive,mustBeNonempty} = 1;
        Name            (1,:) char = 'NO NAME';
        PairName        (1,:) char
        Select          (1,:) char   {mustBeMember(Select,{'auto','random','custom'})} = 'auto';
        SelectFunction  (1,1) 
        ValueBounds     (1,2) double {mustBeNonNan,mustBeNonempty} = [-inf inf];
    end

    properties (Dependent)
        N
        Value
        Values
        
        isBuffer
    end
    
    methods
        function obj = Parameter(varargin)
            if nargin == 0, return; end
            
            p = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(p,varargin{i});
                assert(any(ind),'epsych.Parameter:Parameter:InvalidParameter', ...
                    'Invalid property "%s"',varargin{i})
                obj.(p{ind}) = varargin{i+1};
            end
        end
        
        function set.Index(obj,idx)
            if idx < 1, idx = 1; end
            if idx > obj.N, idx = obj.N; end
            obj.Index = idx;
        end
        
        function n = get.N(obj)
            n = length(obj.Values);
        end
        
        function v = get.Value(obj)
            switch obj.Select
                case 'random'
                    obj.Index = randi(obj.N,1);
                    
                case 'custom'
                    obj.Index = feval(obj.SelectFunction{:});
            end
            
            v = obj.Values(obj.Index);
         
            if v < obj.ValueBounds(1), v = obj.ValueBounds(1); end
            if v > obj.ValueBounds(2), v = obj.ValueBounds(2); end
        end

        function v = get.Values(obj)
            if iscell(obj.Expression)
                v = feval(obj.Expression{:});
                
            elseif ischar(obj.Expression)
                v = eval(obj.Expression);
                
            else
                v = obj.Expression;
            end
        end
        
        function set.ValueBounds(obj,vb)
            assert(numel(vb)==2 & isnumeric(vb),'epsych.Parameter:set.ValueBounds:InvalidEntry', ...
                'Parameter ValueBounds must contain 2 numeric values');
            obj.ValueBounds = sort(vb(:)','ascend');
        end
        
        function set.SelectFunction(obj,h)
            obj.SelectFunction = h;
            obj.Select = 'custom';
        end
        
        function tf = get.isBuffer(obj)
            tf = numel(obj.Value) > 1;
        end
        
    end

    
end