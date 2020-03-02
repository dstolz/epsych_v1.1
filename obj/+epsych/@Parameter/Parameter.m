classdef Parameter < handle & matlab.mixin.Copyable & matlab.mixin.SetGet
    % P = epsych.Parameter('Property','Value',...)

    properties
        Expression      (1,:) char
        Index           (1,:) double {mustBeInteger,mustBePositive,mustBeNonempty} = 1;
        Name            (1,:) char = 'NO NAME';
        PairName        (1,:) char
        Select          (1,:) char   {mustBeMember(Select,{'index','randIndex','randRange','custom'})} = 'index';
        SelectFunction  (1,1) % function handle
        Units           (1,:) char
        UnitScale       (1,1) double = 1;
        ValueBounds     (1,2) double {mustBeNonNan,mustBeNonempty} = [-inf inf];
        Value           (1,1)
        Values          (1,:)

        isLogical       (1,1) logical = false;
        isMultiselect   (1,1) logical = false;
        isRange         (1,1) logical = false;
        isContinuous    (1,1) logical = false;
    end

    properties (Dependent)
        isBuffer
        N
        ValuesStr
    end
    
    methods
        function obj = Parameter(Name,Expression,varargin)
            if nargin == 0, return; end

            if nargin >= 1 && ~isempty(Name), obj.Name = Name; end
            if nargin >= 2 && ~isempty(Expression), obj.Expression = Expression; end
            
            p = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(p,varargin{i});
                assert(any(ind),'epsych.Parameter:Parameter:InvalidParameter', ...
                    'Invalid property "%s"',varargin{i})
                obj.(p{ind}) = varargin{i+1};
            end
        end
        
        function set.Index(obj,idx)
            if idx < 1, idx = 1;         end
            if idx > obj.N, idx = obj.N; end
            obj.Index = idx;
        end
        
        function n = get.N(obj)
            n = length(obj.Values);
        end
        
        function v = get.Value(obj)
            switch obj.Select
                case 'index'
                    v = obj.Values(obj.Index);

                case 'randIndex'
                    obj.Index = randi(obj.N,1);
                    v = obj.Values(obj.Index);        
                
                case 'randRange'
                    s = obj.Values;
                    a = min(s);
                    b = max(s);
                    r = rand(1);
                    v = r * (b - a) + a;
                    
                case 'custom'
                    v = feval(obj.SelectFunction,obj);
                    v = v .* obj.UnitScale;
            end
            
            if v < obj.ValueBounds(1), v = obj.ValueBounds(1); end
            if v > obj.ValueBounds(2), v = obj.ValueBounds(2); end
            
            v = v .* obj.UnitScale;
            
        end

        function v = get.Values(obj)
            if iscell(obj.Expression)
                v = feval(obj.Expression{:});
                
            elseif ischar(obj.Expression)
                v = eval(obj.Expression);
            
            % elseif obj.isBuffer
            %     error('Buffers not yet implemented for Parameter')

            else
                v = obj.Expression;
            end            

        end
        

        function c = get.ValuesStr(obj)
            v = obj.Values;
            if isstring(v)
                c = v;
                return
            end
            
            if isempty(obj.Units)
                c = cellfun(@num2str,v);
            else
                c = arrayfun(@(a) sprintf('%g %s',a,obj.Units),v,'uni',0);
            end
            
            for i = 1:obj.N
                c{i} = num2str(v(i));
                if ~isempty(obj.Units)
                    c{i} = sprintf('%s %s',c{i},obj.Units);
                end
            end
        end

        function set.Value(obj,v)
            obj.Expression = v;
        end

        function set.Values(obj,v)
            obj.Expression = v;
        end

        function set.ValueBounds(obj,vb)
            assert(numel(vb)==2 & isnumeric(vb),'epsych.Parameter:set.ValueBounds:InvalidEntry', ...
                'Parameter ValueBounds must contain 2 numeric values');
            obj.ValueBounds = sort(vb(:)','ascend');
        end
        
        function set.Select(obj,s)
            obj.Select = s;
            switch s
                case 'randRange'
                    assert(obj.N == 2,'epsych.Parameter:set.Select:InvalidNumVals', ...
                        'The randRange select option requires the parameter to have exactly 2 values');
                    obj.isRange = true;
            end
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